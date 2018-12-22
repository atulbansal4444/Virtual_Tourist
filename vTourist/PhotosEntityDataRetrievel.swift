//
//  PhotosEntityDataRetrievel.swift
//  vTourist
//
//  Created by Atul Bansal on 8/15/18.
//  Copyright © 2018 Atul Bansal. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PhotosEntityDataRetrievel: NSManagedObject {
    @NSManaged var image: Data?
    @NSManaged var iURL: String?
    @NSManaged var pin: PinEntityDataRetrievel?
    
    
    @objc convenience init(image:Data?, context: NSManagedObjectContext) {
        if let entty = NSEntityDescription.entity(forEntityName: "Photo", in: context){
            self.init(entity: entty, insertInto: context)
            self.image = image
        } else {
            fatalError("check Entity")
        }
    }
    
}
