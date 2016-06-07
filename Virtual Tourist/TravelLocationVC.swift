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
    
    var fetchResultsController: NSFetchedResultsController!
    
    let appDel = UIApplication.sharedApplication().delegate as! AppDelegate

    
    @IBOutlet weak var mapView: MKMapView!
    
    let flickrClient = FlickrClient()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mapView.mapType = .Standard
        attemptFetch()
    }
    

    @IBAction func dropPin(sender: AnyObject) {
        let theSender = sender as! UIGestureRecognizer
        
        if theSender.state == .Began {
            var location = ""
            var city = ""
            var country = ""
            
            //Reserve geocode location to get city and country for annotation title and add annotation to the map
            let geocoder = CLGeocoder()
            
            //Get location from sender as CGPoint
            let touchPoint = sender.locationInView(mapView)
            
            //Convert location to CLCoordinate2D
            let touchCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
            
            //Create CLLocation to use for reverseGeocodeLocation
            let touchCLLocation = CLLocation(latitude: touchCoordinate.latitude, longitude: touchCoordinate.longitude)
            
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
                let annotation = MKPointAnnotation()
                annotation.coordinate = touchCoordinate
                
                if location.isEmpty == false && city.isEmpty == true {
                    annotation.title = "\(location)"
                } else {
                    annotation.title = "\(city), \(country)"
                }
                self.mapView.addAnnotation(annotation)
                
                Pin(latitude: touchCoordinate.latitude, longitude: touchCoordinate.longitude, title: annotation.title!, context: self.appDel.managedObjectContext)
                
                do {
                    try self.appDel.managedObjectContext.save()
                    print("we saved the pin!")
                } catch {
                    print("We couldnt save the pin!")
                    abort()
                }
            }
        }
    }
    
    // MARK: - Fetchresults Controller
    
    func attemptFetch() {
        setFetchRequest()
        
        do {
            try self.fetchResultsController.performFetch()
            
            let results = fetchResultsController.fetchedObjects as? [Pin]
            
            if let result = results {
                for pin in result {
                    let annotation = MKPointAnnotation()
                    let coordinate = CLLocationCoordinate2D(latitude: Double(pin.latitude!), longitude: Double(pin.longitude!))
                    annotation.coordinate = coordinate
                    annotation.title = pin.locationTitle
                    print(annotation)
                    mapView.addAnnotation(annotation)
                }
            }
            
        } catch {
            print("Error executing fetch request: \(error)")
        }
        
    }
    
    func setFetchRequest() {
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDel.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        controller.delegate = self
        
        fetchResultsController = controller
    }
}

