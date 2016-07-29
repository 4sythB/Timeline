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

class Post: SyncableObject, SearchableRecord, CloudKitManagedObject {
    
    static let recordTypeKey = "Post"
    static let photoDataKey = "photo"
    static let timestampKey = "timestamp"
    
    var recordType = Post.recordTypeKey
    
    lazy var temporaryPhotoURL: NSURL = {
        
        // Must write to temporary directory to be able to pass image file path url to CKAsset
        
        let temporaryDirectory = NSTemporaryDirectory()
        let temporaryDirectoryURL = NSURL(fileURLWithPath: temporaryDirectory)
        let fileURL = temporaryDirectoryURL.URLByAppendingPathComponent(self.recordName).URLByAppendingPathExtension("jpg")
        
        self.photoData?.writeToURL(fileURL, atomically: true)
        
        return fileURL
    }()
    
    var cloudKitRecord: CKRecord? {
        
        let recordID = CKRecordID(recordName: recordName)
        let record = CKRecord(recordType: recordType, recordID: recordID)
        
        let photoAsset = CKAsset(fileURL: temporaryPhotoURL)
        
        record["photo"] = photoAsset
        record["timestamp"] = self.timestamp
        
        return record
    }
    
    var photo: UIImage? {
        
        guard let photoData = self.photoData else { return nil }
        
        return UIImage(data: photoData)
    }
    
    convenience init?(photo: NSData, timestamp: NSDate = NSDate(), context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        guard let entity = NSEntityDescription.entityForName("Post", inManagedObjectContext: context) else { return nil }
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.photoData = photo
        self.timestamp = timestamp
        self.recordName = NSUUID().UUIDString
    }
    
    convenience required init?(record: CKRecord, context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        
        guard let timestamp = record.creationDate,
            let photoData = record[Post.photoDataKey] as? CKAsset else { return nil }
        
        guard let entity = NSEntityDescription.entityForName(Post.recordTypeKey, inManagedObjectContext: context) else { fatalError("Error: Core Data failed to create entity from entity description.") }
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.timestamp = timestamp
        self.photoData = NSData(contentsOfURL: photoData.fileURL)
        self.recordIDData = NSKeyedArchiver.archivedDataWithRootObject(record.recordID)
        self.recordName = record.recordID.recordName
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
