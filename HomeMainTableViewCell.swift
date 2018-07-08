//
//  HomeMainTableViewCell.swift
//  HomeyBeta
//
//  Created by jonathan laroco on 6/30/18.
//  Copyright © 2018 Johnny Laroco. All rights reserved.
//

import UIKit

class HomeMainTableViewCell: UITableViewCell {

    @IBOutlet weak var UsernameTxt: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var subtitleTxt: UILabel!
    @IBOutlet weak var userPostTxt: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
        profileImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func set(post:HomePost) {
        ImageService.getImage(withURL: post.author.photoURL) { image in
            self.profileImageView.image = image
        }
        let postDate = NSDate(timeIntervalSince1970: post.timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        subtitleTxt.text = formatter.string(from: postDate as Date)
        //subtitleTxt.text = String(format:"%.1f", post.timestamp)
        UsernameTxt.text = post.author.username
        userPostTxt.text = post.text
    }
    
}
