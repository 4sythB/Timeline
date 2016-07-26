//
//  Comment.swift
//  Timeline
//
//  Created by Brad on 7/25/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import CoreData

class Comment: SyncableObject, SearchableRecord {

    convenience init?(post: Post, text: String, timestamp: NSDate = NSDate(), context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        guard let entity = NSEntityDescription.entityForName("Comment", inManagedObjectContext: context) else { return nil }
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.post = post
        self.text = text
        self.timestamp = timestamp
        self.recordName = NSUUID().UUIDString
    }
    
    func matchesSearchTerm(searchTerm: String) -> Bool {
        
        if self.text.containsString(searchTerm) {
            return true
        } else {
            return false
        }
    }
}
