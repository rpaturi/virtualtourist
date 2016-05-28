//
//  Photo+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Rachel Paturi on 5/27/16.
//  Copyright © 2016 Rachel Paturi. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Photo {

    @NSManaged var photo: NSObject?
    @NSManaged var pin: NSManagedObject?

}
