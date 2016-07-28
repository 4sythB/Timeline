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

class PostController {
    
    static let sharedController = PostController()
    
    let cloudKitManager = CloudKitManager()
    
    let moc = Stack.sharedStack.managedObjectContext
    
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
        
        guard let cloudKitRecord = post.cloudKitRecord else { return }
        cloudKitManager.saveRecord(cloudKitRecord) { (record, error) in
            guard error == nil else { print(error?.localizedDescription); return }
            if let record = record {
                post.update(record)
            }
        }
        
        saveContext()
    }
    
    func addCommentToPost(text: String, post: Post) {
        guard let comment = Comment(post: post, text: text) else { return }
        print(comment.cloudKitRecord)
            guard let cloudKitRecord = comment.cloudKitRecord else {
                return }
        print(cloudKitRecord)
        
        cloudKitManager.saveRecord(cloudKitRecord) { (record, error) in
            if error != nil { print(error?.localizedDescription) }
            if let record = record {
                comment.update(record)
            }
        }
        
        saveContext()
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
}







