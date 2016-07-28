//
//  Comment.swift
//  Timeline
//
//  Created by Brad on 7/25/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class Comment: SyncableObject, SearchableRecord, CloudKitManagedObject {
    
    static private let kTimestamp = "timestamp"
    static private let kText = "text"
    
    var recordType: String {
        return "Comment"
    }
    
    var cloudKitRecord: CKRecord? {

        guard let postRecord = post.cloudKitRecord else { return nil }
        let reference = CKReference(record: postRecord, action: .DeleteSelf)
        
        let record = CKRecord(recordType: recordType)
        
        record[Comment.kTimestamp] = self.timestamp
        record[Comment.kText] = self.text
        record["reference"] = reference
        
        return record
    }

    convenience init?(post: Post, text: String, timestamp: NSDate = NSDate(), context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        guard let entity = NSEntityDescription.entityForName("Comment", inManagedObjectContext: context) else { return nil }
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.post = post
        self.text = text
        self.timestamp = timestamp
        self.recordName = NSUUID().UUIDString
    }
    
    convenience required init?(record: CKRecord, context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        guard let entity = NSEntityDescription.entityForName("Comment", inManagedObjectContext: context), timestamp = record[Comment.kTimestamp] as? NSDate, text = record[Comment.kText] as? String, _ = record["reference"] as? CKReference else { return nil }
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.timestamp = timestamp
        self.text = text
        self.recordName = record.recordID.recordName
        self.recordIDData = NSKeyedArchiver.archivedDataWithRootObject(record.recordID)
    }
    
    func matchesSearchTerm(searchTerm: String) -> Bool {
        
        if self.text.containsString(searchTerm) {
            return true
        } else {
            return false
        }
    }
}
