//
//  AppDelegate.swift
//  vTourist
//
//  Created by Atul Bansal on 8/15/18.
//  Copyright © 2018 Atul Bansal. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }


    let save = CoreDataStack(modelName: "vTourist")
    @objc func preloadData() {
        do{
            try save!.dropAllData()
            print("Data Cleaned Successfully")
        }
        catch{
            print("Error!")
        }
    }
 }



