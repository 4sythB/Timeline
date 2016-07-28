//
//  CloudKitManagedObject.swift
//  Timeline
//
//  Created by Brad on 7/27/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

@objc protocol CloudKitManagedObject {
    
    var timestamp: NSDate { get set }        // date and time the object was created
    var recordIDData: NSData? { get set }    // persisted CKRecordID
    var recordName: String { get set }       // unique name for the object
    var recordType: String { get }           // a consistent type string, 'Post' for Post, 'Comment' for Comment
    
    var cloudKitRecord: CKRecord? { get }    // a generated record representation of the `NSManagedObject` that can be saved to CloudKit (similar to `dictionaryValue` when working with REST APIs)
    
    init?(record: CKRecord, context: NSManagedObjectContext)  // to initialize a new `NSManagedObject` from a `CKRecord` from CloudKit (similar to `init?(json: [String: AnyObject])` when working with REST APIs)
    
//    func updateWithRecord(record: CKRecord)
}

extension CloudKitManagedObject {
    
    // helper variable to determine if a CloudKitManagedObject has a CKRecordID, which we can use to say that the record has been saved to the server
    var isSynced: Bool {
        
        if recordIDData != nil {
            return true
        } else {
            return false
        }
    }
    
    // a computed property that unwraps the persisted recordIDData into a CKRecordID, or returns nil if there isn't one
    var cloudKitRecordID: CKRecordID? {
        
        guard let recordIDData = recordIDData else { return nil }
        
        let ckRecordID = NSKeyedUnarchiver.unarchiveObjectWithData(recordIDData) as? CKRecordID
        
        return ckRecordID
    }
    
    // a computed property that returns a CKReference to the object in CloudKit
    var cloudKitReference: CKReference? {
        
        guard let ckRecordID = cloudKitRecordID else { return nil }
        
        let ckReference = CKReference(recordID: ckRecordID, action: .DeleteSelf)
        
        return ckReference
    }
    
    // called after saving the object, saved the record.recordID to the recordIDData
    func update(record: CKRecord) {
        recordIDData = NSKeyedArchiver.archivedDataWithRootObject(record.recordID)
        
        do {
            try Stack.sharedStack.managedObjectContext.save()
        } catch {
            print("Error: Unable to save to moc.")
        }
    }
    
    var nameForManagedObject: NSUUID {
        return NSUUID()
    }
}













