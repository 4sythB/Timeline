//
//  Post.swift
//  Timeline
//
//  Created by Brad on 7/25/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import CoreData


class Post: SyncableObject, SearchableRecord {
    
    convenience init?(photo: NSData, timestamp: NSDate = NSDate(), context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        guard let entity = NSEntityDescription.entityForName("Post", inManagedObjectContext: context) else { return nil }
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.photoData = photo
        self.timestamp = timestamp
        self.recordName = NSUUID().UUIDString
    }
    
    func matchesSearchTerm(searchTerm: String) -> Bool {
        guard let comments = comments else { return false }
        
        let results = comments.flatMap { $0.text.containsString(searchTerm) ? true : false }
        
        if results.contains(true) {
            return true
        } else {
            return false
        }
    }
}
