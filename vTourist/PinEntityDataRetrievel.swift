//
//  PinEntityDataRetrievel.swift
//  vTourist
//
//  Created by Atul Bansal on 8/15/18.
//  Copyright © 2018 Atul Bansal. All rights reserved.
//

import UIKit
import CoreData

class PinEntityDataRetrievel: NSManagedObject {
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var num: NSNumber?
    @NSManaged var photo: NSSet?
    
    @objc convenience init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        if let entity = NSEntityDescription.entity(forEntityName: "Pin", in:context){
            self.init(entity: entity, insertInto: context)
            self.latitude = latitude as NSNumber?
            self.longitude = longitude as NSNumber?
        } else {
            fatalError("check Entity")
        }
    }
    
}

