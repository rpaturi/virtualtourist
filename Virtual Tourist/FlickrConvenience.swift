//
//  FlickrConvenience.swift
//  Virtual Tourist
//
//  Created by Rachel Paturi on 5/31/16.
//  Copyright © 2016 Rachel Paturi. All rights reserved.
//

import UIKit
import CoreData
import MapKit

extension FlickrClient {
    func searchPhotoByLocation(latitude: Float, longitude: Float, completionHandlerForSearch: (result: AnyObject?, error: NSError?) -> Void) {
        let parameters: [String:AnyObject] = [
            FlickrClient.FlickrParameterKeys.Method : FlickrClient.FlickrParameterValues.PhotoSearchMethod,
            FlickrClient.FlickrParameterKeys.ApiKey: FlickrClient.FlickrParameterValues.APIKey,
            FlickrClient.FlickrParameterKeys.Latitude: latitude,
            FlickrClient.FlickrParameterKeys.Longitude : longitude,
            FlickrClient.FlickrParameterKeys.Format : FlickrClient.FlickrParameterValues.FormatResponse,
            FlickrClient.FlickrParameterKeys.NoJSONCallback : FlickrClient.FlickrParameterValues.DisableJSONCallback
        ]
        
        taskForGetMethod("", parameters: parameters) { (result, error) in
            guard (error == nil) else {
                completionHandlerForSearch(result: nil, error: error)
                print("\(error?.userInfo)")
                return
            }
            
            guard let result = result else {
                print("Sorry we didnt get a result from searchByPhoto")
                return
            }
            
            guard let photosArray = result["photos"] as? [String : AnyObject] else {
                completionHandlerForSearch(result: nil, error: error)
                print("We could not find the 'photos' key in \(result["photos"])")
                return
            }
            
            //print(photosArray)
            
            guard let photoArray = photosArray["photo"] as? [[String:AnyObject]] else {
                completionHandlerForSearch(result: nil, error: error)
                print("We could not find the 'photo' key in \(photosArray["photo"])")
                return
            }
            
            print(photoArray)
            
            completionHandlerForSearch(result: photosArray, error: nil)
            
        }
    }
}