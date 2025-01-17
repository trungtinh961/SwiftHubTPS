//
//  UserCell.swift
//  SwifthubTPS
//
//  Created by TPS on 8/27/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var imgAuthor: UIImageView!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lbFullname: UILabel!
    @IBOutlet weak var lbDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
      
        mainView.layer.cornerRadius = 5
        imgAuthor.layer.cornerRadius = imgAuthor.frame.height / 2
        imgUser.layer.cornerRadius = imgUser.frame.height / 2
        imgAuthor.layer.masksToBounds = true
        imgUser.layer.masksToBounds = true
        imgAuthor.image = UIImage(named: ImageName.launch_image.rawValue)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
