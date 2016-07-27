//
//  Post.swift
//  Timeline
//
//  Created by Brad on 7/25/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import CoreData
import CloudKit
import UIKit

class Post: SyncableObject, SearchableRecord {
    
    var recordType: String {
        return "Post"
    }
    
    lazy var temporaryPhotoURL: NSURL = {
        
        // Must write to temporary directory to be able to pass image file path url to CKAsset
        
        let temporaryDirectory = NSTemporaryDirectory()
        let temporaryDirectoryURL = NSURL(fileURLWithPath: temporaryDirectory)
        let fileURL = temporaryDirectoryURL.URLByAppendingPathComponent(self.recordName).URLByAppendingPathExtension("jpg")
        
        self.photoData.writeToURL(fileURL, atomically: true)
        
        return fileURL
    }()
    
    var cloudKitRecord: CKRecord? {
        
        let record = CKRecord(recordType: recordType)
        
        let photoAsset = CKAsset(fileURL: temporaryPhotoURL)
        
        record["photo"] = photoAsset
        record["timestamp"] = self.timestamp
        
        return record
    }
    
    convenience init?(photo: NSData, timestamp: NSDate = NSDate(), context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        guard let entity = NSEntityDescription.entityForName("Post", inManagedObjectContext: context) else { return nil }
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.photoData = photo
        self.timestamp = timestamp
        self.recordName = NSUUID().UUIDString
    }
    
    convenience init?(record: CKRecord, context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        guard let entity = NSEntityDescription.entityForName("Post", inManagedObjectContext: context), timestamp = record["timestamp"] as? NSDate, photoData = record["photo"] as? NSData else { return nil }
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.timestamp = timestamp
        self.photoData = photoData
        self.recordName = record.recordID.recordName
        self.recordIDData = NSKeyedArchiver.archivedDataWithRootObject(record.recordID)
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
