//
//  PhotoAlbumVC.swift
//  VirtualTourist
//
//  Created by 🍑 on 29/12/2019.
//  Copyright © 2019 udacity. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumVC: UIViewController, MKMapViewDelegate, UICollectionViewDataSource {
    
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var pin: Pin!
    var pageNumber = 0
    var photosExist: Bool {
        return (fetchedResultsController.fetchedObjects?.count) != 0 ? true : false }
    
    //MARK:- Outlets
    @IBOutlet weak var noImageLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var loadButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    //MARK:- Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setFlowLayout()
        setAnnotation()
        setUpFetchedResultsController()
        if !photosExist {
            print("start fetching")
            fetchPhotos()
        }
        collectionView?.reloadData()
        navigationItem.title = "Tap on 📍 photo to delete"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView?.reloadData()
    }
    //MARK:- Core data functions
    func setUpFetchedResultsController(){
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "pin == %@", pin)
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            fatalError("Error fetching data: \(error.localizedDescription)")
        }
    }
    //MARK:- Network functions
    func fetchPhotos() {
        print("fetching")
        self.loadingView(true)
        VTClient.getPhotos(coordinate: CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude), page: pageNumber) { (urls, error, errorMsg) in
            if error != nil {
                DispatchQueue.main.async {
                    self.showAlertMessage("Error", error!.localizedDescription)
                }
            }
            if urls.count != 0 {
                for url in urls {
                    let photo = Photo(context: DataController.viewContext)
                    photo.url = url
                    photo.pin = self.pin
                }
                try? DataController.viewContext.save()
                self.loadingView(false)
            } else {
                DispatchQueue.main.async {
                    self.showAlertMessage("", "No photos were found ☹️")
                    self.loadingView(false)
                    self.noImageLabel.isHidden = true
                }
            }
            self.collectionView.reloadData()
        }
    }
    //MARK:- UI Configurations
    func setFlowLayout() {
        let space:CGFloat = 2.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    func loadingView(_ loading:Bool){
        loading ? startAI() : stopAI()
        noImageLabel.isHidden=self.photosExist
        if !noImageLabel.isHidden {
            noImageLabel.text = "Loading Images"
        }
        loadButton.isEnabled = !loading
    }
    //MARK:- Map pins configurations & Map view delegates
    func setAnnotation() {
        let annotaion = MKPointAnnotation()
        annotaion.coordinate = pin.coordinate
        self.mapView.addAnnotation(annotaion)
        self.mapView.selectAnnotation(annotaion, animated: false)
        let span = MKCoordinateSpan(latitudeDelta: 0.35, longitudeDelta: 0.35)
        let region = MKCoordinateRegion(center: annotaion.coordinate, span: span)
        self.mapView.setRegion(region, animated: false)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    @IBAction func loadButtonPressed(_ sender: Any) {
        pageNumber+=1
        fetchPhotos()
        collectionView.reloadData()
    }
    
}

//MARK:- Collection view and Results controller delegates
extension PhotoAlbumVC: NSFetchedResultsControllerDelegate, UICollectionViewDelegate {
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }

     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! PhotoCollectionViewCell
        cell.photo = fetchedResultsController.object(at: indexPath)
        return cell
    }

     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = fetchedResultsController?.object(at: indexPath)
        DataController.viewContext.delete(photo!)
        try? DataController.viewContext.save()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            collectionView.reloadData()
        case .insert:
            collectionView.reloadData()
        case .move:
            collectionView.reloadData()
        case .update:
            collectionView.reloadData()
        @unknown default:
            return
        }
    }

}
