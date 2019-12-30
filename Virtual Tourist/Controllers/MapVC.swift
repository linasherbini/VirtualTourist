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
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupFetchedResultsController()
        setAnnotations()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(pinDeletion))
        editingMode = false
    }
    
    @objc func pinDeletion() {
        if !editingMode {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneDeleting))
            editingMode = true
        }
    }
    
    @objc func doneDeleting() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(pinDeletion))
        editingMode = false
    }

    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            showAlertMessage("Error", error.localizedDescription)
        }
    }

    func setAnnotations() {
        var annotations = [MKPointAnnotation]()
        for pin in fetchedResultsController?.fetchedObjects ?? [] {
            let lat = CLLocationDegrees(pin.latitude)
            let long = CLLocationDegrees(pin.longitude)
            let coordination = CLLocationCoordinate2D(latitude: lat, longitude: long)
            self.annotation = MKPointAnnotation()
            self.annotation.coordinate = coordination
            annotations.append(self.annotation)
        }
        mapView.showAnnotations(annotations, animated: true)
    }
    
    @IBAction func newPin(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let pin = Pin(context: DataController.viewContext)
            let location = sender.location(in: self.mapView)
            let coordinations = mapView.convert(location, toCoordinateFrom: mapView)
            pin.latitude = coordinations.latitude
            pin.longitude = coordinations.longitude
            pins.append(pin)
            let annotation = MKPointAnnotation()
            annotation.coordinate = pin.coordinate
            mapView.addAnnotation(annotation)
            do {
                try DataController.viewContext.save()
            } catch {
                showAlertMessage("Error", error.localizedDescription)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhotos" {
            let photoAlbumVC = segue.destination as! PhotoAlbumVC
            photoAlbumVC.pin = sender as! Pin
        }
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else {
            return
        }
        
        if editingMode {
            let pin = (fetchedResultsController?.fetchedObjects?.first(where: {$0.latitude == annotation.coordinate.latitude && $0.longitude == annotation.coordinate.longitude}))!
            self.mapView.removeAnnotation(annotation)
            DataController.deletePin(pin)
            do {
                try DataController.viewContext.save()
            } catch {
                showAlertMessage("Error", error.localizedDescription)
            }
        } else {
            let pin = (fetchedResultsController?.fetchedObjects?.first(where: {$0.latitude == annotation.coordinate.latitude && $0.longitude == annotation.coordinate.longitude}))! 
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
    
    func showAlertMessage(_ title: String, _ message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
