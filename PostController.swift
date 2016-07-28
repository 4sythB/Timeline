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
    
    let cloudKitManager = CloudKitManager()
    
    let moc = Stack.sharedStack.managedObjectContext
    
    init() {
        
        performFullSync()
    }
    
    func saveContext() {
        do {
            try moc.save()
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            print(error.userInfo)
        }
    }
    
    func createPost(image: UIImage, caption: String) {
        guard let imageData: NSData = UIImagePNGRepresentation(image), post = Post(photo: imageData) else { return }
        
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
        
        guard let cloudKitRecord = comment.cloudKitRecord else { return }
        
        saveContext()
        
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
        
        let fetchRequest = NSFetchRequest(entityName: "Post")
        let predicate = NSPredicate(format: "recordName == %@", argumentArray: [name])
        fetchRequest.predicate = predicate
        
        let result = (try? Stack.sharedStack.managedObjectContext.executeFetchRequest(fetchRequest) as? [Post]) ?? nil
        
        return result?.first
    }
    
    // MARK: - Sync
    
    func syncedRecords(type: String) -> [CloudKitManagedObject] {
        
        let request = NSFetchRequest(entityName: type)
        let predicate = NSPredicate(format: "recordData != nil")
        
        request.predicate = predicate
        
        guard let results = try? (Stack.sharedStack.managedObjectContext.executeFetchRequest(request)) as? [CloudKitManagedObject] ?? [] else { return [] }
        
        return results
    }
    
    func unsyncedRecords(type: String) -> [CloudKitManagedObject] {
        
        let request = NSFetchRequest(entityName: type)
        let predicate = NSPredicate(format: "recordData == nil")
        
        request.predicate = predicate
        
        guard let results = try? (Stack.sharedStack.managedObjectContext.executeFetchRequest(request)) as? [CloudKitManagedObject] ?? [] else { return [] }
        
        return results
    }
    
    func fetchNewRecords(type: String, completion: (() -> Void)?) {
        
        let referencesToExclude = syncedRecords(type).flatMap { $0.cloudKitReference }
        
        var predicate = NSPredicate(format: "NOT(recordID IN %@)", argumentArray: [referencesToExclude])
        
        if referencesToExclude.isEmpty {
            predicate = NSPredicate(value: true)
        }
        
        cloudKitManager.fetchRecordsWithType(type, predicate: predicate, recordFetchedBlock: { (record) in
            
            switch type {
            case Post.recordTypeKey: _ = Post(record: record)
            case Comment.recordTypeKey: _ = Comment(record: record)
            default: return
            }
            
            self.saveContext()
            
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
            
            if let matchingRecord = unsavedManagedObjects.filter({ $0.recordName == record.recordID.recordName }).first {
                matchingRecord.update(record)
            }
            
        }) { (records, error) in
            
            if let completion = completion {
                let success = records != nil
                completion(success: success, error: error)
            }
        }
    }
    
    func performFullSync(completion: (() -> Void)? = nil) {
        
        pushChangestoCloudKit { (success, error) in
            if success == success {
                self.fetchNewRecords(Post.recordTypeKey, completion: {
                    self.fetchNewRecords(Comment.recordTypeKey, completion: {
                        if let completion = completion {
                            completion()
                        }
                    })
                })
            }
        }
    }
}











