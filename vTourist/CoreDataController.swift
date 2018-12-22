//
//  CoreDataController.swift
//  vTourist
//
//  Created by Atul Bansal on 8/15/18.
//  Copyright © 2018 Atul Bansal. All rights reserved.
//


import Foundation
import UIKit
import CoreData

class CoreDataController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    @objc let delegate = UIApplication.shared.delegate as! AppDelegate
    @objc var selectedIndexes = [IndexPath]()
    @objc var insertedIndexPaths = [IndexPath]()
    @objc var deletedIndexPaths = [IndexPath]()
    @objc var updatedIndexPaths = [IndexPath]()
    @objc var fetchedResultsController : NSFetchedResultsController<PhotosEntityDataRetrievel>?{
        didSet{
            self.fetchedResultsController?.delegate = self
            self.executeSearch()
        }
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    @objc func executeSearch(){
        if let fc = fetchedResultsController{
            do{
                try fc.performFetch()
            }catch {
                print("Fetching Not Possible")
            }
        }
    }
}

extension CoreDataController{
    @objc func numberOfSectionsInCollectionView(_ collectionView: UICollectionView) -> Int {
        if let count = self.fetchedResultsController{
            return (count.sections?.count)!
        } else {
            return 0
        }
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sec = self.fetchedResultsController!.sections {
            return sec[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    @objc(collectionView:didSelectItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        if let fetchedController = self.fetchedResultsController {
            fetchedController.managedObjectContext.delete((fetchedResultsController?.object(at: indexPath))! as NSManagedObject)
            delegate.save?.save()
        }
    }
}

extension CoreDataController: NSFetchedResultsControllerDelegate{
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.insertedIndexPaths = [IndexPath]()
        self.deletedIndexPaths = [IndexPath]()
        self.updatedIndexPaths = [IndexPath]()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.insertedIndexPaths.append(newIndexPath!)
            break
        case .delete:
            self.deletedIndexPaths.append(indexPath!)
            break
        case .update:
            self.updatedIndexPaths.append(indexPath!)
            break
        default:
            return
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.imageCollectionView.performBatchUpdates({ () -> Void in
            for i in self.insertedIndexPaths {
                self.imageCollectionView.insertItems(at: [i])
            }
            for i in self.deletedIndexPaths {
                self.imageCollectionView.deleteItems(at: [i])
            }
            for i in self.updatedIndexPaths {
                self.imageCollectionView.reloadItems(at: [i])
            }
        }, completion: nil)
    }
}

