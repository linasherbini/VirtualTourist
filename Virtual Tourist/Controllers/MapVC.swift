//
//  MapVC.swift
//  VirtualTourist
//
//  Created by 🍑 on 08/12/2019.
//  Copyright © 2019 udacity. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapVC: UIViewController, MKMapViewDelegate {

    var pins: [Pin] = []
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    var dataController: DataController!
    var annotation: MKPointAnnotation!
    var editingMode: Bool!
    
    //MARK:- Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK:- Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
        setAnnotations()
        defaultNavigationItem()
        editingMode = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        defaultNavigationItem()
    }
    
    //MARK:- Core Data functions
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            self.showAlertMessage("Error", error.localizedDescription)
        }
    }

    //MARK:- UI Configuration functions
    fileprivate func defaultNavigationItem() {
           self.navigationItem.title = "Tap & hold to drop 📍"
           navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(pinDeletion))
       }
    
    @objc func pinDeletion() {
        if !editingMode {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneDeleting))
            self.navigationItem.title = "Tap 📍 to delete"
            editingMode = true
        }
    }
    
    @objc func doneDeleting() {
        defaultNavigationItem()
        editingMode = false
    }

    //MARK:- Map pins configurations & Map view delegates
    func setAnnotations() {
        var annotations = [MKPointAnnotation]()
        let pins = DataController.getPins()
        for pin in pins {
            let lat = CLLocationDegrees(pin.latitude)
            let long = CLLocationDegrees(pin.longitude)
            let coordination = CLLocationCoordinate2D(latitude: lat, longitude: long)
            self.annotation = MKPointAnnotation()
            self.annotation.coordinate = coordination
            annotations.append(self.annotation)
        }
        mapView.showAnnotations(annotations, animated: true)
    }
    //Will delete pins if editing is enabled, and will transition to photo album view if editing is disabled
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else {
            return
        }
        if editingMode {
            let pin = (fetchedResultsController?.fetchedObjects?.first(where: {$0.latitude == annotation.coordinate.latitude && $0.longitude == annotation.coordinate.longitude}))!
            self.mapView.removeAnnotation(annotation)
            DataController.deletePin(pin)
            try? DataController.viewContext.save()
        }
        if !editingMode {
            let pin = DataController.getPins().first(where: {$0.latitude == annotation.coordinate.latitude && $0.longitude == annotation.coordinate.longitude})
            navigationItem.title = "🌏"
            performSegue(withIdentifier: "showPhotos", sender: pin)
        }
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
    
    @IBAction func newPin(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let location = sender.location(in: self.mapView)
            let coordinations = mapView.convert(location, toCoordinateFrom: mapView)
            let pin = DataController.savePin(longitude: coordinations.longitude, latitude: coordinations.latitude)
            pins.append(pin)
            let annotation = MKPointAnnotation()
            annotation.coordinate = pin.coordinate
            mapView.addAnnotation(annotation)
            DataController.saveContext()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhotos" {
            let photoAlbumVC = segue.destination as! PhotoAlbumVC
            photoAlbumVC.pin = sender as! Pin
        }
    }
}
