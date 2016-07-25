//
//  PostController.swift
//  Timeline
//
//  Created by Brad on 7/25/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import UIKit

class PostController {
    
    static let sharedController = PostController()
    
    let moc = Stack.sharedStack.managedObjectContext
    
    func saveContext() {
        do {
            try moc.save()
        } catch {
            print("Unable to save context.")
        }
    }
    
    func createPost(image: UIImage, caption: String) {
        guard let imageData: NSData = UIImagePNGRepresentation(image) else { return }
        _ = Post(photo: imageData, comments: caption)
        saveContext()
    }
    
    func addCommentToPost(text: String, post: Post) {
        _ = Comment(post: post, text: text)
        saveContext()
    }
}