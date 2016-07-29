//
//  PostTableViewCell.swift
//  Timeline
//
//  Created by Brad on 7/25/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateWithPost(post: Post) {
        
        postImageView.image = post.photo
    }
}
