//
//  PostDetailTableViewController.swift
//  Timeline
//
//  Created by Brad on 7/25/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit
import CoreData

class PostDetailTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var postImageView: UIImageView!
    
    var post: Post?
    
    let moc = Stack.sharedStack.managedObjectContext
    
    let postController = PostController()
    
    var fetchedResultsController: NSFetchedResultsController = NSFetchedResultsController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        
        if let post = post {
            updateWithPost(post)
        }
        
        setupFetchedResultsController()
    }
    
    func setupFetchedResultsController() {
        
        guard let post = post else { return }
        let request = NSFetchRequest(entityName: "Comment")
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        request.predicate = NSPredicate(format: "post == %@", post)
        
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: "timestamp", cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        fetchedResultsController.delegate = self
    }
    
    func updateWithPost(post: Post) {
        let imageData = post.photoData
        guard let image: UIImage = UIImage(data: imageData) else { return }
        postImageView.image = image
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("postDetailCell", forIndexPath: indexPath)
        
        guard let comments = post?.comments, post = post else { return UITableViewCell() }
        let comment = comments[indexPath.row] as Comment
        
        cell.textLabel?.text = comment.text
        cell.detailTextLabel?.text = "\(post.timestamp)"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            guard let post = fetchedResultsController.objectAtIndexPath(indexPath) as? Post else { return }
            PostController.sharedController.deletePost(post)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func commentButtonTapped(sender: AnyObject) {
        
        let alert = UIAlertController(title: "Add a comment", message: nil, preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler { (commentTextField) in
            commentTextField.placeholder = "Comment"
        }
        
        let commentAction = UIAlertAction(title: "Comment", style: .Default) { (commentAction) in
            guard let commentTextField = alert.textFields?[0],
                comment = commentTextField.text else { return }
            
            if comment.characters.count > 0 {
                guard let post = self.post else { return }
                self.postController.addCommentToPost(comment, post: post)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        alert.addAction(commentAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func shareButtonTapped(sender: AnyObject) {
        
    }
    
    @IBAction func followPostButtonTapped(sender: AnyObject) {
        
    }
    
    // MARK: - NSFetchedResultsControllerDelegate Methods
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        case .Insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
        case .Update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        case .Move:
            guard let indexPath = indexPath, newIndexPath = newIndexPath else { return }
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}


























