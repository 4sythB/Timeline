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
        
        _ = Comment(post: post, text: caption)
        saveContext()
    }
    
    func addCommentToPost(text: String, post: Post) {
        _ = Comment(post: post, text: text)
        saveContext()
    }
    
    func deletePost(post: Post) {
        moc.deleteObject(post)
        saveContext()
    }
}