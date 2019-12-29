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

class PhotoAlbumVC: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var noImageLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var loadButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var pin: Pin!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = NSPredicate(format: "pin == %@", pin)
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController?.fetchedObjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        <#code#>
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = fetchedResultsController?.object(at: indexPath)
        DataController.viewContext.delete(photo!)
        try? DataController.viewContext.save()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .blue
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }

}
