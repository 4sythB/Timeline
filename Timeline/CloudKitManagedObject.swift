//
//  CloudKitManagedObject.swift
//  Timeline
//
//  Created by Caleb Hicks on 5/28/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

@objc protocol CloudKitManagedObject {
    
    var added: NSDate? { get set }
    var recordData: NSData? { get set }
    var recordName: String { get set }
    var recordType: String { get }
    var cloudKitRecord: CKRecord? { get }
    
    func updateWithRecord(record: CKRecord)
}

extension CloudKitManagedObject {
    
    
    var cloudKitRecordID: CKRecordID? {
        guard let record = cloudKitRecord else { return nil }
        return record.recordID
    }
    
    var cloudKitRecordName: String? {
        guard let recordName = cloudKitRecordID?.recordName else { return nil }
        return recordName
    }
    
    var cloudKitReference: CKReference? {
        
        guard let record = cloudKitRecord else { return nil }
        
        return CKReference(record: record, action: .None)
    }
    
    var isSynced: Bool {
        
        return recordData != nil
    }
    
    var creatorRecord: CKRecordID? {
        guard let record = cloudKitRecord else { return nil }
        return record.creatorUserRecordID
    }
    
    func nameForManagedObject() -> String {
        let uuid = NSUUID()
        
        let name = "\(self.recordType)-\(uuid.UUIDString)"
        
        print("generated name for managed object: \(name)")
        
        return name
    }
}