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

class PhotoAlbumVC: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate{
    let fc = NSFetchedResultsController()
    var location: CLLocationCoordinate2D?
    
    @IBOutlet weak var theCollectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        //Make sure the location information was sent from TravelLocationVC
        if let theLocation = location {
            //Set map coordinates and zoom into the location
            self.mapView.centerCoordinate = theLocation
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = theLocation
            self.mapView.addAnnotation(annotation)
            
            let latDegrees = 0.05
            let longDegrees = 0.05
            
            let span: MKCoordinateSpan = MKCoordinateSpanMake(latDegrees, longDegrees)
            let region: MKCoordinateRegion = MKCoordinateRegionMake(theLocation, span)
            
            self.mapView.setRegion(region, animated: true)
        }
        
        fc.delegate = CoreDataCollectionViewDelegate(collectionView: theCollectionView)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        mapView.mapType = .Standard
        
        print(location)
    }
    
    //MARK: UICollectionView implementation
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FlickrPhotoCell", forIndexPath: indexPath) as! FlickrPhotoCell
        
        return cell
    }
    
}

