//
//  CoreData.swift
//  vTourist
//
//  Created by Atul Bansal on 8/15/18.
//  Copyright © 2018 Atul Bansal. All rights reserved.
//

import Foundation
import CoreData

struct CoreDataStack {
    fileprivate let model : NSManagedObjectModel
    fileprivate let storeCoordinator : NSPersistentStoreCoordinator
    fileprivate let modelURL : URL
    fileprivate let dbURL : URL
    fileprivate let persistingContext : NSManagedObjectContext
    let backgroundContext : NSManagedObjectContext
    let context : NSManagedObjectContext
    init?(modelName: String){
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") else {
            return nil
            
        }
        self.modelURL = modelURL
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else{
            return nil
        }
        self.model = model
        storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        persistingContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        persistingContext.persistentStoreCoordinator = storeCoordinator
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = persistingContext
        backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.parent = context
        let fmanager = FileManager.default
        guard let  docUrl = fmanager.urls(for: .documentDirectory, in: .userDomainMask).first else{
            return nil
        }
        self.dbURL = docUrl.appendingPathComponent("model.sqlite")
        let options = [NSInferMappingModelAutomaticallyOption: true, NSMigratePersistentStoresAutomaticallyOption: true]
        do{
            try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: options)
            
        }catch{
            print("\(dbURL)")
        }
    }
    
    func addStoreCoordinator(_ storeType: String,
                             configuration: String?,
                             storeURL: URL,
                             options : [AnyHashable: Any]?) throws{
        try storeCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: dbURL, options: nil)
    }
}

extension CoreDataStack  {
    func dropAllData() throws{
        try storeCoordinator.destroyPersistentStore(at: dbURL, ofType:NSSQLiteStoreType , options: nil)
        try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: nil)
    }
}

extension CoreDataStack {
    typealias Batch=(_ workerContext: NSManagedObjectContext) -> ()
    func performBackgroundBatchOperation(_ batch: @escaping Batch ){
        backgroundContext.perform(){
            batch(self.backgroundContext)
            do{
                try self.backgroundContext.save()
            }catch{
                fatalError("\(error)")
            }
        }
    }
}
extension CoreDataStack {
    func save() {
        context.performAndWait(){
            if self.context.hasChanges{
                do{
                    try self.context.save()
                }catch{
                    fatalError("\(error)")
                }
                self.persistingContext.perform(){
                    do{
                        try self.persistingContext.save()
                    }catch{
                        fatalError("\(error)")
                    }
                }
            }
        }
    }
    func autoSave(_ delayInSeconds : Int){
        if delayInSeconds > 0 {
            save()
            let delayInNanoSeconds = UInt64(delayInSeconds) * NSEC_PER_SEC
            let time = DispatchTime.now() + Double(Int64(delayInNanoSeconds)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                self.autoSave(delayInSeconds)
            })
        }
    }
}

