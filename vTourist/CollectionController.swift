//
//  CollectionController.swift
//  vTourist
//
//  Created by Atul Bansal on 8/15/18.
//  Copyright © 2018 Atul Bansal. All rights reserved.
//


import Foundation
import UIKit
import MapKit
import CoreData

class CollectionController: CoreDataController, MKMapViewDelegate {
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var addNewCollection: UIButton!
    @objc var ann = [MKPointAnnotation]()
    @objc var pinData : PinEntityDataRetrievel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.isUserInteractionEnabled = false
        self.addNewCollection.isEnabled = false
        let Latitude = CLLocationDegrees(truncating: (self.pinData.latitude)!)
        let Longitude = CLLocationDegrees(truncating: (self.pinData.longitude)!)
        let pinCoordinate = CLLocationCoordinate2D(latitude: Latitude, longitude: Longitude)
        let annotations = MKPointAnnotation()
        annotations.coordinate = pinCoordinate
        ann.append(annotations)
        map.addAnnotations(ann)
        let latitudeDel:CLLocationDegrees = 2.25
        let longitudeDel:CLLocationDegrees = 2.25
        let span: MKCoordinateSpan = MKCoordinateSpanMake(latitudeDel, longitudeDel)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(pinCoordinate, span)
        map.setRegion(region, animated: true)
        let fetchResults = NSFetchRequest<PhotosEntityDataRetrievel>(entityName: "Photo")
        fetchResults.sortDescriptors = [NSSortDescriptor(key: "pin", ascending: true)]
        fetchResults.predicate =  NSPredicate(format: "pin = %@", argumentArray: [self.pinData])
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchResults, managedObjectContext: (delegate.save?.context)!, sectionNameKeyPath: nil, cacheName: nil)
        if (pinData.photo?.count)! < 1 {
            self.background(){ (success, error) in
                self.performUpdates{
                    self.addNewCollection.isEnabled = true
                }
                if success == false {
                    self.performUpdates{
                        let downloadAlert = UIAlertController(title: nil, message: error, preferredStyle: UIAlertControllerStyle.alert)
                        downloadAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (UIAlertAction) in
                        }))
                        self.present(downloadAlert, animated: true, completion: nil)                    }
                }
                self.delegate.save?.save()
            }
        } else {
            self.addNewCollection.isEnabled = true
        }
    }
    
    
    
    @objc func collectionView(_ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        let cellImage = collectionView.dequeueReusableCell(withReuseIdentifier: "Image", for: indexPath) as! CollectionCell
        cellImage.activityIndicator.isHidden = false
        cellImage.activityIndicator.startAnimating()
        cellImage.collectionImageView.image = nil
        let rowInCollectionView = fetchedResultsController!.object(at: indexPath)
        if rowInCollectionView.image == nil  {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                let imageDisplay = try? Data(contentsOf: URL(string:(rowInCollectionView.iURL)!)!)
                self.fetchedResultsController?.managedObjectContext.perform{
                    rowInCollectionView.image = imageDisplay
                    self.delegate.save?.save()
                }
            }
        }
        if rowInCollectionView.image != nil {
            cellImage.collectionImageView?.image = UIImage(data:(rowInCollectionView.image)!)
            cellImage.activityIndicator.stopAnimating()
            cellImage.activityIndicator.isHidden = true
        }
        return cellImage
    }
    
    
    
    @objc func background(_ completion: @escaping (_ success: Bool, _ error: String?) -> Void) {
        let imageDownload = FlickerData()
        imageDownload.displayImage(self.pinData) { (results, pageNumber, error) in
            func Error(_ error: String) {
                completion(false, error)
            }
            guard (error == nil) else {
                Error(error!)
                return
            }
            for pic in results!{
                guard let Image = pic["url_m"] as? String else {
                    return
                }
                self.fetchedResultsController?.managedObjectContext.perform{
                    let Photo = PhotosEntityDataRetrievel(image: nil, context: (self.fetchedResultsController!.managedObjectContext))
                    Photo.iURL = Image
                    Photo.pin = self.pinData
                    self.pinData.num = pageNumber as NSNumber?
                }
            }
            completion(true, nil)
        }
    }
    
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let Id = "pins"
        var pinPlaced = mapView.dequeueReusableAnnotationView(withIdentifier: Id) as? MKPinAnnotationView
        if pinPlaced == nil {
            pinPlaced = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Id)
            pinPlaced!.pinTintColor = .green
        } else {
            pinPlaced!.annotation = annotation
        }
        return pinPlaced
    }
    
    
    
    @IBAction func newCollection(_ sender: Any) {
        addNewCollection.isEnabled = false
        let photoRetrieved = (self.pinData.photo!) as NSSet
        for pic in photoRetrieved{
            self.fetchedResultsController?.managedObjectContext.delete(pic as! NSManagedObject)
        }
        background(){ (success, error) in
            self.performUpdates{
                self.addNewCollection.isEnabled = true
            }
            if success == false {
                self.performUpdates{
                    let downloadAlert = UIAlertController(title: nil, message: error, preferredStyle: UIAlertControllerStyle.alert)
                    downloadAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (UIAlertAction) in
                    }))
                    self.present(downloadAlert, animated: true, completion: nil)
                }
            }
            self.delegate.save?.save()
        }
    }
    
    
    @objc func performUpdates(_ updates: @escaping () -> Void) {
        DispatchQueue.main.async {
            updates()
        }
    }
    
}

