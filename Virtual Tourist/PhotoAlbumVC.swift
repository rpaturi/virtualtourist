//
//  PhotoAlbumVC.swift
//  Virtual Tourist
//
//  Created by Rachel Paturi on 6/1/16.
//  Copyright © 2016 Rachel Paturi. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumVC: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        mapView.mapType = .Standard
    }
}
