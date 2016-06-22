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
    
    var fetchResultsController: NSFetchedResultsController!
    var selectedPin : Pin!
    var selectedPhotos: [Photo] = []
    var downloadedPhotos: [Photo] = []
    
    var linkArray: [String] = []
    var location: CLLocationCoordinate2D?
    
    @IBOutlet weak var theCollectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        //Make sure the location information was sent from TravelLocationVC
        let anno = MKPointAnnotation()
        anno.coordinate = CLLocationCoordinate2D(latitude: Double(selectedPin.latitude!), longitude: Double(selectedPin.longitude!))
        
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
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //Allow user to select multiple photos in collection to delete
        theCollectionView.allowsSelection = true
        theCollectionView.allowsMultipleSelection = true
        mapView.mapType = .Standard
        
        attemptPinFetch()
        
        print(location)
        //print("I am printing the selectedPin from the PhotoAlbumVC: \(selectedPin)")
    }
    
    //MARK: UICollectionView implementation
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count: Int?
        
        guard let theSelectedPin = selectedPin else {
            print("There was no selected pin")
            return 0
        }
        
        if theSelectedPin.photos?.count > 0 {
            count = selectedPin.photos?.count
        } else {
            count = 0
        }
        return count!
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FlickrPhotoCell", forIndexPath: indexPath) as! FlickrPhotoCell
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    
    //Execute fetchRequest and use results returned from setFetchRequest
    func attemptPinFetch() {
        setFetchRequest("Pin", sortDescriptorKey: "creationDate")
        
        do {
            try self.fetchResultsController.performFetch()
            
            let results = fetchResultsController.fetchedObjects as? [Pin]
            
            if let result = results {
                for pin in result {
                    if pin.latitude == location?.latitude && pin.longitude == location?.longitude {
                        selectedPin = pin
                        
                        if let selectedPinPhotos = selectedPin.photos {
                            print(selectedPinPhotos)
                            if selectedPinPhotos.count == 0 {
                                //Download images from Flickr
                                downloadPhotosFromFlicker()
                                
                                //New Collection Button should be displayed
                            } else {
                                //Display images from
                                //Edit Collection Button should be displayed
                            }
                        }
                        print("I am print the \(selectedPin)")
                    }
                }
            }
        } catch {
            print("Error executing fetch request: \(error)")
        }
    }
    
    // Set up fetch request
    func setFetchRequest(entityName: String, sortDescriptorKey: String) {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        
        let sortDescriptor = NSSortDescriptor(key: sortDescriptorKey, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDel.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        controller.delegate = self
        
        fetchResultsController = controller
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        theCollectionView.reloadData()
    }
    
    func downloadPhotosFromFlicker() {
        
        if let location = location {
            FlickrClient.sharedInstance().searchPhotoByLocation(location.latitude, longitude: location.longitude, completionHandlerForSearch: { (result, error) in
                
                guard (error == nil) else {
                    print("There was an error: \(error?.localizedDescription)")
                    return
                }
                
                if let results = result {
                    self.linkArray = results as! [String]
                    
                    for link in self.linkArray {
                        let url = NSURL(string: link)
                        if let url = url {
                            let data = NSData(contentsOfURL: url)
                            let photo = Photo(data: data!, context: appDel.managedObjectContext)
                            photo.pin = self.selectedPin
                            
                            let image = UIImage(data: data!)
                
                            FlickrClient.sharedInstance().imageCache.setObject(image!, forKey: url)
                            
                            print("We inserted photo into context")
                        } else {
                            //Display error that we wouldnt save the phont
                            print("Couldnt save the photo")
                        }
                    }
                    
                    appDel.saveContext()
                } else {
                    print("There were no results passed in from the completionHandlerForGet")
                }
            })
        }
    }
    
    //IF app gets too large, this will clear the cache
    override func didReceiveMemoryWarning() {
        FlickrClient.sharedInstance().imageCache.removeAllObjects()
    }
}

