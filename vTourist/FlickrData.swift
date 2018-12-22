//
//  FlickrData.swift
//  vTourist
//
//  Created by Atul Bansal on 8/15/18.
//  Copyright © 2018 Atul Bansal. All rights reserved.
//


import Foundation
import CoreData
import UIKit
class FlickerData {
    
    func flickrURL(_ parameters: [String:AnyObject]) -> URL {
        
        var pinURL = URLComponents()
        pinURL.scheme = "https"
        pinURL.host = "api.flickr.com"
        pinURL.path = "/services/rest"
        pinURL.queryItems = [URLQueryItem]()
        
        for (i, j) in parameters {
            let Item = URLQueryItem(name: i, value: "\(j)")
            pinURL.queryItems!.append(Item)
        }
        
        return pinURL.url!
    }
    let delegate = UIApplication.shared.delegate as! AppDelegate

    func displayImage(_ pin: PinEntityDataRetrievel, completionHandler: @escaping (_ results: [[String:AnyObject]]?, _ pagesNumber: Int, _ error: String?) -> Void)  {
        
        var numOfPage = Int()
        if pin.num == 0 {
            numOfPage = 1
        } else {
            numOfPage = Int(arc4random_uniform(UInt32((numOfPage))))
        }
        let URL : [String: String?] = ["method":"flickr.photos.search", "api_key": "7f6b159b2f9fed38522f0f1ae91c7f38", "bbox": bBox((pin.latitude as? Double)!, Long: (pin.longitude as? Double)!), "extras": "url_m", "page": String(numOfPage), "format" : "json", "nojsoncallback": "1"]
        
        let requestURL = URLRequest(url: flickrURL(URL as [String : AnyObject]))
        
        let taskData = URLSession.shared.dataTask(with: requestURL, completionHandler: { (data, response, error) in
            
            func Error(_ error: String) {
                completionHandler(nil, 0, error)
            }
            
            guard (error == nil) else {
                Error((error?.localizedDescription)!)
                return
            }
            
            guard let status = (response as? HTTPURLResponse)?.statusCode , status >= 200 && status <= 299 else {
                Error("Status Code was \(String(describing: response as? HTTPURLResponse))?.statusCode)")
                return
            }
            guard let dataFromURL = data else {
                Error("Data Not Found")
                return
            }
            
            var parsing: AnyObject!
            do {
                parsing = try JSONSerialization.jsonObject(with: dataFromURL, options: .allowFragments) as AnyObject?
            } catch {
                Error("Data Paring not Possible")
            }
            
            guard let dictionary = parsing["photos"] as? [String:AnyObject] else {
                return
            }
            guard let pages = dictionary["pages"] as? Int else {
                return
            }
            guard let arrayOfPhotos = dictionary["photo"] as? [[String:AnyObject]] else {
                return
            }
            var finalPhotoArray = [[String:AnyObject]]()
            let number = Int(arc4random_uniform(UInt32(arrayOfPhotos.count - 12)))
            var photoIndex = 0
            var Limit = 0
            for i in arrayOfPhotos {
                if photoIndex >= number {
                    if Limit < 20 {
                        finalPhotoArray.append(i)
                        Limit += 1
                    }
                }
                photoIndex = photoIndex + 1
            }
            completionHandler(finalPhotoArray, pages, nil)
        })
        taskData.resume()
    }
    func bBox(_ Lat: Double, Long: Double) -> String {
        let minLongitude = min(Long + 1, 180)
        let maxLongitude = max(Long - 1, -180)
        let minLatitude = min(Lat + 1, 90)
        let maxLatitude = max(Lat - 1, -90)
        return "\(maxLongitude),\(maxLatitude),\(minLongitude),\(minLatitude)"
    }
    
}


