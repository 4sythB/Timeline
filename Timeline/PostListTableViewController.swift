//
//  PostListTableViewController.swift
//  Timeline
//
//  Created by Brad on 7/25/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit
import CoreData

class PostListTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating {
    
    let moc = Stack.sharedStack.managedObjectContext
    
    var fetchedResultsController: NSFetchedResultsController = NSFetchedResultsController()
    
    var searchController: UISearchController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFetchedResultsController()
        setUpSearchController()
    }
    
    func setupFetchedResultsController() {
        
        let request = NSFetchRequest(entityName: "Post")
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        fetchedResultsController.delegate = self
    }
    
    func setUpSearchController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let resultsController = storyboard.instantiateViewControllerWithIdentifier("resultsController")
        
        searchController = UISearchController(searchResultsController: resultsController)
        guard let searchController = searchController else { return }
        
        searchController.searchResultsUpdater = self
        
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.placeholder = "Search"
        searchController.definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        guard let text = searchController.searchBar.text?.lowercaseString,
            resultsController = searchController.searchResultsController as? SearchResultsTableViewController,
            let posts = fetchedResultsController.fetchedObjects as? [Post] else { return }
        
        resultsController.resultsArray = posts.filter { $0.matchesSearchTerm(text) }
        resultsController.tableView.reloadData()
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
        guard let cell = tableView.dequeueReusableCellWithIdentifier("postCell", forIndexPath: indexPath) as? PostTableViewCell,
            post = fetchedResultsController.objectAtIndexPath(indexPath) as? Post else { return UITableViewCell() }
        
        cell.updateWithPost(post)
        
        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            guard let post = fetchedResultsController.objectAtIndexPath(indexPath) as? Post else { return }
            PostController.sharedController.deletePost(post)
        }
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
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toPostDetail" {
            
            if let detailViewController = segue.destinationViewController as? PostDetailTableViewController,
                let selectedIndexPath = self.tableView.indexPathForSelectedRow,
                let post = fetchedResultsController.objectAtIndexPath(selectedIndexPath) as? Post {
                
                detailViewController.post = post
            }
        }
        
        if segue.identifier == "toPostDetailFromSearch" {
            if let detailViewController = segue.destinationViewController as? PostDetailTableViewController,
                let sender = sender as? PostTableViewCell,
                let selectedIndexPath = (searchController?.searchResultsController as? SearchResultsTableViewController)?.tableView.indexPathForCell(sender),
                let searchTerm = searchController?.searchBar.text?.lowercaseString,
                let posts = fetchedResultsController.fetchedObjects?.filter({ $0.matchesSearchTerm(searchTerm) }) as? [Post] {
                
                let post = posts[selectedIndexPath.row]
                
                detailViewController.post = post
            }
        }
    }
}






