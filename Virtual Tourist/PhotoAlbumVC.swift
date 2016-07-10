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
    
    var selectedPin : Pin!
    var selectedPhotos: [NSIndexPath] = []
    
    var linkArray: [String] = []
    var location: CLLocationCoordinate2D?
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var theCollectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var saveCollectionButton: UIButton!
    @IBOutlet weak var removePhotoButton: UIButton!
    
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
        
        if selectedPin.photos!.count == 0 {
            downloadPhotosFromFlicker()
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
        
        removePhotoButton.hidden = true
        saveCollectionButton.hidden = false
        
        //attemptPhotoFetch()
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("There was an error")
        }
        
    }
    
    //MARK: UICollectionView implementation
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let photoCount = selectedPin.photos?.count {
            return photoCount
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        //let placeHolderImage = UIImage(named: "PlaceholderPhoto")
        
        //let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FlickrPhotoCell", forIndexPath: indexPath) as! FlickrPhotoCell
        
        configureCell(cell, indexPath: indexPath)
        
        return cell

    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        selectedPhotos.append(indexPath)
        print(selectedPhotos.count)
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        cell?.alpha = 0.5
        
        determineButton()
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if let index = selectedPhotos.indexOf(indexPath) {
            selectedPhotos.removeAtIndex(index)
        }
        print(selectedPhotos.count)
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        cell?.alpha = 1.0
        
        determineButton()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        theCollectionView.reloadData()
    }
    
    func configureCell(cell: FlickrPhotoCell, indexPath: NSIndexPath) {
        var photoImage = UIImage(named: "PlaceholderPhoto")

        //Get photo from fetched results
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        
        //Checks if photo was saved in coredata or needs to be downloaded
        if photo.photoURL == nil || photo.photoURL == "" {
            photoImage = UIImage(named: "PlaceholderPhoto")
        } else if photo.photo != nil {
            photoImage = UIImage(data: photo.photo!)
        } else {
            FlickrClient.sharedInstance().taskToDownloadPhotos(photo.photoURL!, completionHandlerForDownloadPhotos: { (data, error) in
                    guard (error == nil) else {
                        return
                    }
                
                if let data = data {
                    photo.photo = data
                    photoImage = UIImage(data: data)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        cell.imageView!.image = photoImage
                    }
                }
            })
        }
        
        cell.imageView!.image = photoImage
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
                        
                        let photo = Photo(photoURL: link, context: appDel.managedObjectContext)
                        photo.pin = self.selectedPin

                    }
                    
                    appDel.saveContext()
                } else {
                    print("There were no results passed in from the completionHandlerForGet")
                }
            })
        }
    }
    
    @IBAction func removePhotosFromCollection(sender: AnyObject) {
        var photosToDelete: [Photo] = []
        
        for indexPath in selectedPhotos {
            photosToDelete.append(fetchedResultsController.objectAtIndexPath(indexPath) as! Photo)
            theCollectionView.cellForItemAtIndexPath(indexPath)?.alpha = 1.0
        }
        
        for photo in photosToDelete {
            appDel.managedObjectContext.deleteObject(photo)
            print("We deleted the photo")
        }
        
        selectedPhotos.removeAll()
        
        do {
            try appDel.managedObjectContext.save()
            
        }catch {
            //EEROR ALERT
        }
        
        determineButton()
        
    }
    
    
    @IBAction func newCollection(sender: AnyObject) {
        selectedPhotos.removeAll()
        
        let photos = fetchedResultsController.fetchedObjects as! [Photo]
        
        for photo in photos {
            appDel.managedObjectContext.deleteObject(photo)
        }
        
        downloadPhotosFromFlicker()
        
        determineButton()
    }
    
    func determineButton() {
        if selectedPhotos.count > 0 {
            removePhotoButton.hidden = false
            saveCollectionButton.hidden = true
        } else {
            removePhotoButton.hidden = true
            saveCollectionButton.hidden = false
        }
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        
        let sortDescriptor = NSSortDescriptor(key: "photoURL", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let predicate = NSPredicate(format: "pin = %@", self.selectedPin)
        fetchRequest.predicate = predicate
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDel.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        frc.delegate = self
        
        return frc
    }()

}

