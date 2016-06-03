//
//  TravelLocationVC.swift
//  Virtual Tourist
//
//  Created by Rachel Paturi on 5/27/16.
//  Copyright © 2016 Rachel Paturi. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData
import ContactsUI

class TravelLocationVC: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    var fetchResultsController: NSFetchedResultsController!{
        didSet{
            fetchResultsController.delegate = self
        }
    }
    
    let appDel = UIApplication.sharedApplication().delegate as! AppDelegate

    
    @IBOutlet weak var mapView: MKMapView!
    
    let flickrClient = FlickrClient()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mapView.mapType = .Standard
        
    }
    

    @IBAction func dropPin(sender: AnyObject) {
        var location = ""
        var city = ""
        var country = ""
        let annotation = MKPointAnnotation()
        
        //Get location from sender as CGPoint
        let touchPoint = sender.locationInView(mapView)
        
        //Convert location to CLCoordinate2D
        let touchCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
        
        //Create CLLocation to use for reverseGeocodeLocation
        let touchCLLocation = CLLocation(latitude: touchCoordinate.latitude, longitude: touchCoordinate.longitude)
        
        //Reserve geocode location to get city and country for annotation title and add annotation to the map
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(touchCLLocation) { (placemarks, error) in
            guard (error == nil) else {
                print("There was an error: \(error?.userInfo)")
                return
            }
            
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            // Location name
            if let locationName = placeMark.addressDictionary!["Name"] as? NSString {
                location = locationName as String
            }
            
            //City
            if let theCity = placeMark.addressDictionary!["City"] as? NSString {
                city = theCity as String
            }
            
            //Country
            if let theCountry = placeMark.addressDictionary!["Country"] as? NSString {
                country = theCountry as String
            }
            
            annotation.coordinate = touchCoordinate
            
            if location.isEmpty == false && city.isEmpty == true {
                annotation.title = "\(location)"
            } else {
                annotation.title = "\(city), \(country)"
            }
            self.mapView.addAnnotation(annotation)
            
            let pin = Pin(latitude: touchCoordinate.latitude, longitude: touchCoordinate.longitude, title: annotation.title!, context: self.appDel.managedObjectContext)
        }  
    }
}

