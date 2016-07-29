//
//  PostController.swift
//  Timeline
//
//  Created by Brad on 7/25/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import CloudKit

class PostController {
    
    static let sharedController = PostController()
    let cloudKitManager: CloudKitManager
    let moc = Stack.sharedStack.managedObjectContext
    
    var isSyncing: Bool = false
    
    init() {
        self.cloudKitManager = CloudKitManager()
        performFullSync()
    }
    
    // MARK: - Core Data
    
    func saveContext() {
        do {
            try moc.save()
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            print(error.userInfo)
        }
    }
    
    func createPost(image: UIImage, caption: String) {
        guard let imageData: NSData = UIImageJPEGRepresentation(image, 0.8), post = Post(photo: imageData) else { return }
        
        addCommentToPost(caption, post: post)
        
        saveContext()
        
        guard let cloudKitRecord = post.cloudKitRecord else { return }
        cloudKitManager.saveRecord(cloudKitRecord) { (record, error) in
            guard error == nil else { print(error?.localizedDescription); return }
            if let record = record {
                post.update(record)
            }
        }
    }
    
    func addCommentToPost(text: String, post: Post) {
        guard let comment = Comment(post: post, text: text) else { return }
        
        saveContext()
        
        guard let cloudKitRecord = comment.cloudKitRecord else { return }
        cloudKitManager.saveRecord(cloudKitRecord) { (record, error) in
            if error != nil { print(error?.localizedDescription) }
            if let record = record {
                comment.update(record)
            }
        }
    }
    
    func deletePost(post: Post) {
        moc.deleteObject(post)
        saveContext()
    }
    
    func postWithName(name: String) -> Post? {
        
        let fetchRequest = NSFetchRequest(entityName: Post.recordTypeKey)
        let predicate = NSPredicate(format: "recordName == %@", argumentArray: [name])
        fetchRequest.predicate = predicate
        
        let result = (try? Stack.sharedStack.managedObjectContext.executeFetchRequest(fetchRequest) as? [Post]) ?? nil
        
        return result?.first
    }
    
    // MARK: - Sync w/ CloudKit
    
    func syncedRecords(type: String) -> [CloudKitManagedObject] {
        
        let request = NSFetchRequest(entityName: type)
        let predicate = NSPredicate(format: "recordIDData != nil")
        
        request.predicate = predicate
        
        let results = (try? Stack.sharedStack.managedObjectContext.executeFetchRequest(request)) as? [CloudKitManagedObject] ?? []
        
        return results
    }
    
    func unsyncedRecords(type: String) -> [CloudKitManagedObject] {
        
        let request = NSFetchRequest(entityName: type)
        let predicate = NSPredicate(format: "recordIDData == nil")
        
        request.predicate = predicate
        
        let results = (try? Stack.sharedStack.managedObjectContext.executeFetchRequest(request)) as? [CloudKitManagedObject] ?? []
        
        return results
    }
    
    func fetchNewRecords(type: String, completion: (() -> Void)?) {
        
        var referencesToExclude = [CKReference]()
        let moc = Stack.sharedStack.managedObjectContext
        var predicate: NSPredicate!
        
        moc.performBlockAndWait {
            referencesToExclude = self.syncedRecords(type).flatMap { $0.cloudKitReference }
            predicate = NSPredicate(format: "NOT(recordID IN %@)", argumentArray: [referencesToExclude])
            
            if referencesToExclude.isEmpty {
                predicate = NSPredicate(value: true)
            }
        }
        
        cloudKitManager.fetchRecordsWithType(type, predicate: predicate, recordFetchedBlock: { (record) in
            
            moc.performBlock {
                switch type {
                    
                case Post.recordTypeKey:
                    let _ = Post(record: record)
                case Comment.recordTypeKey:
                    let _ = Comment(record: record)
                default:
                    return
                }
                
                self.saveContext()
            }
            
        }) { (records, error) in
            if error != nil {
                print("Error: Unable to fetch new records")
            }
            
            if let completion = completion {
                completion()
            }
        }
    }
    
    func pushChangestoCloudKit(completion: ((success: Bool, error: NSError?) -> Void)?) {
        
        let unsavedManagedObjects = unsyncedRecords(Post.recordTypeKey) + unsyncedRecords(Comment.recordTypeKey)
        
        let unsavedRecords = unsavedManagedObjects.flatMap({ $0.cloudKitRecord })
        
        cloudKitManager.saveRecords(unsavedRecords, perRecordCompletion: { (record, error) in
            
            guard let record = record else { return }
            
            let moc = Stack.sharedStack.managedObjectContext
            moc.performBlock {
                if let matchingRecord = unsavedManagedObjects.filter({ $0.recordName == record.recordID.recordName }).first {
                    
                    matchingRecord.update(record)
                }
            }
            
        }) { (records, error) in
            
            if let completion = completion {
                let success = records != nil
                completion(success: success, error: error)
            }
        }
    }
    
    func performFullSync(completion: (() -> Void)? = nil) {
        
        if isSyncing {
            completion?()
            
        } else {
            
            isSyncing = true
            
            pushChangestoCloudKit { (success, error) in
                
                self.fetchNewRecords(Post.recordTypeKey, completion: {
                    self.fetchNewRecords(Comment.recordTypeKey, completion: {
                        self.isSyncing = false
                        completion?()
                    })
                })
                
                if error != nil {
                    print(error?.localizedDescription)
                }
            }
        }
    }
}











