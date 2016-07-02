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
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
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
        mapView.mapType = .Standard
        
        //Calculating and setting the 2 column layout for collection view
        let space: CGFloat = 3.0
        let dimension = (view.frame.size.width - (3 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSizeMake(dimension, dimension)
        
        //Allow user to select multiple photos in collection to delete
        theCollectionView.allowsSelection = true
        theCollectionView.allowsMultipleSelection = true
        
        attemptPhotoFetch()
        
    }
    
    //MARK: UICollectionView implementation
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let frc = fetchResultsController {
            return frc.sections![section].numberOfObjects;
        }else{
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let photo = fetchResultsController.objectAtIndexPath(indexPath) as! Photo
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FlickrPhotoCell", forIndexPath: indexPath) as! FlickrPhotoCell
        cell.imageView.image = UIImage(data: photo.photo!)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func attemptPhotoFetch() {
        setPhotoRequest("Photo", sortDescriptorKey: "photoURL")
        
        do {
            try self.fetchResultsController.performFetch()
            
            let results = fetchResultsController.fetchedObjects as? [Photo]
            
            if selectedPin.photos!.count == 0 {
                downloadPhotosFromFlicker()
            } else {
                if let result = results {
                    print(result.count)
                    for photo in result {
                        downloadedPhotos.append(photo)
                    }
                }
            }
        } catch {
            print("Error executing fetch request: \(error)")
        }
    }
    
    func setPhotoRequest(entityName: String, sortDescriptorKey: String) {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        
        let sortDescriptor = NSSortDescriptor(key: sortDescriptorKey, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let predicate = NSPredicate(format: "pin = %@", selectedPin)
        fetchRequest.predicate = predicate
        
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
                
                //TODO: Alert if no photos were returned
                
                if let results = result {
                    self.linkArray = results as! [String]
                    
                    for link in self.linkArray {
                        let url = NSURL(string: link)
                        if let url = url {
                            let data = NSData(contentsOfURL: url)
                            let photo = Photo(data: data!, photoURL: link, context: appDel.managedObjectContext)
                            photo.pin = self.selectedPin
                            
                            let image = UIImage(data: data!)
                
                            FlickrClient.sharedInstance().imageCache.setObject(image!, forKey: link)
                            
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

