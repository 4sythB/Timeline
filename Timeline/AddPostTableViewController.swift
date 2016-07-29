//
//  AddPostTableViewController.swift
//  Timeline
//
//  Created by Brad on 7/25/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit

class AddPostTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var selectImageButton: UIButton!
    @IBOutlet weak var commentTextField: UITextField!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
    }
    
    // MARK: - Actions
    
    @IBAction func selectImageButtonTapped(sender: AnyObject) {
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
        
        selectImageButton.setTitle("", forState: .Normal)
    }
    
    @IBAction func addPostButtonTapped(sender: AnyObject) {
        guard let image = postImageView.image, comment = commentTextField.text where comment.characters.count > 0 else {
            displayAlert()
            return
        }
        
        PostController.sharedController.createPost(image, caption: comment)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            postImageView.contentMode = .ScaleAspectFit
            postImageView.image = pickedImage
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func displayAlert() {
        
        let alert = UIAlertController(title: "Oops!", message: "Something's missing", preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        
        alert.addAction(okAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
}








