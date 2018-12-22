//
//  ViewController.swift
//  vTourist
//
//  Created by Atul Bansal on 8/15/18.
//  Copyright © 2018 Atul Bansal. All rights reserved.
//
import UIKit
import CoreData
import Foundation
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    @objc var fetchedResults : NSFetchedResultsController<PinEntityDataRetrievel>!
    
    @objc let fetchPins = NSFetchRequest<PinEntityDataRetrievel>(entityName: "Pin")
    @objc let Descriptors = [NSSortDescriptor(key: "latitude", ascending: true), NSSortDescriptor(key: "longitude", ascending: false)]

    @objc var An = [MKPointAnnotation]()
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    @objc let delegates = UIApplication.shared.delegate as! AppDelegate
    @objc var deletionOfPins: Bool = false
    @objc var app: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        doneButton.isEnabled = false
        let gesture = UILongPressGestureRecognizer(target: self, action:#selector(ViewController.TapHandleFunc(_:)))
        gesture.minimumPressDuration = 0.5
        gesture.allowableMovement = 1
        gesture.delegate = self
        mapView.addGestureRecognizer(gesture)
        UIView.setAnimationDuration(0.5)
        UIView.setAnimationDelegate(self)
        UIView.setAnimationBeginsFromCurrentState(true)
        fetchPins.sortDescriptors = Descriptors
        fetchedResults = NSFetchedResultsController(fetchRequest: fetchPins, managedObjectContext: (delegates.save?.context)!, sectionNameKeyPath: nil, cacheName: nil)
        fetchData()
        for i in fetchedResults.fetchedObjects! {
            let a = i
            let Latitude = CLLocationDegrees(truncating: (a.latitude)!)
            let Longitude = CLLocationDegrees(truncating: (a.longitude)!)
            let coordinates = CLLocationCoordinate2D(latitude: Latitude, longitude: Longitude)
            let Annotation = MKPointAnnotation()
            Annotation.coordinate = coordinates
            An.append(Annotation)
            mapView.addAnnotations(An)
            
        }
    }
    
    @objc func fetchData() {
        do{
            try fetchedResults.performFetch()
        }catch {
            print("Error! Fetching not possible")
        }
    }
    
   
    @objc func TapHandleFunc(_ gesture: UILongPressGestureRecognizer) {
        if (gesture.state == UIGestureRecognizerState.began) {
            if !deletionOfPins {
                let locationPinned = gesture.location(in: mapView)
                let coordinates = mapView.convert(locationPinned,toCoordinateFrom: mapView)
                let Pin = MKPointAnnotation()
                Pin.coordinate = coordinates
                An.append(Pin)
                mapView.addAnnotations(An)
                _ = PinEntityDataRetrievel(latitude: Pin.coordinate.latitude, longitude: Pin.coordinate.longitude, context: (self.fetchedResults.managedObjectContext))
                delegates.save?.save()
            }
        }
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var noOfPins = mapView.dequeueReusableAnnotationView(withIdentifier: "pins") as? MKPinAnnotationView
        if noOfPins == nil {
            noOfPins = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pins")
            noOfPins!.pinTintColor = .green
        }
        else {
            noOfPins!.annotation = annotation
        }
        return noOfPins
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        fetchPins.sortDescriptors = Descriptors
        let predicate = NSPredicate(format: "latitude = %@", argumentArray: [(view.annotation?.coordinate.latitude)!])
        let predicates = NSPredicate(format: "longitude = %@", argumentArray: [(view.annotation?.coordinate.longitude)!])
        let Predicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate, predicates])
        fetchPins.predicate = Predicate
        fetchData()
        let pinsAdded = fetchedResults?.fetchedObjects
        let selectedPin = pinsAdded![0]
        if deletionOfPins {
            var index = 0
            for items in An {
                if selectedPin.latitude as! Double == items.coordinate.latitude && selectedPin.longitude as! Double == items.coordinate.longitude  {
                    mapView.removeAnnotations(An)
                    An.remove(at: index)
                    fetchedResults.managedObjectContext.delete(selectedPin)
                    delegates.save?.save()
                    mapView.addAnnotations(An)
                    return
                }
                index = index + 1
            }
        }
        else {
            let CollectionView = self.storyboard!.instantiateViewController(withIdentifier: "CollectionController") as! CollectionController
            CollectionView.pinData = selectedPin
            self.navigationController!.pushViewController(CollectionView, animated: true)
            mapView.deselectAnnotation(view.annotation, animated: false)
        }
    }
    @IBAction func doneButtonAction(_ sender: Any) {
        deletionOfPins = false
        editButton.isEnabled = true
        doneButton.isEnabled = false
        UIView.beginAnimations(nil, context: nil)
        UIView.commitAnimations()
        app = true
    }
    @IBAction func editButtonAction(_ sender: Any) {
        editButton.isEnabled = false
        doneButton.isEnabled = true
        UIView.beginAnimations(nil, context: nil)
        UIView.commitAnimations()
        deletionOfPins = true
    }
    
    
}

