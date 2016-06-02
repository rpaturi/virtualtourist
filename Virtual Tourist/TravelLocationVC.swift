//
//  TravelLocationVC.swift
//  Virtual Tourist
//
//  Created by Rachel Paturi on 5/27/16.
//  Copyright © 2016 Rachel Paturi. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationVC: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let flickrClient = FlickrClient()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mapView.mapType = .Standard
        
        flickrClient.searchPhotoByLocation(41.8781, longitude: 87.6298) { (result, error) in
            guard (error == nil) else {
                print("\(error)")
                return
            }
            
            guard let result = result  else {
                print("Sorry we didnt get a result")
                return
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

