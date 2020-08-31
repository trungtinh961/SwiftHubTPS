//
//  RepositoryCell.swift
//  SwifthubTPS
//
//  Created by TPS on 8/26/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import UIKit

class RepositoryCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    

    @IBOutlet weak var imgAuthor: UIImageView!
    
    @IBOutlet weak var imgCurrentPeriodStars: UIImageView!
    
    @IBOutlet weak var lbFullname: UILabel!
    
    @IBOutlet weak var lbDescription: UILabel!
    
    @IBOutlet weak var lbStars: UILabel!
    
    @IBOutlet weak var lbCurrentPeriodStars: UILabel!
    
    @IBOutlet weak var lbLanguage: UILabel!
    @IBOutlet weak var viewLanguageColor: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
      
        mainView.layer.cornerRadius = 5
        viewLanguageColor.layer.cornerRadius = viewLanguageColor.frame.width / 2
        imgAuthor.layer.cornerRadius = imgAuthor.frame.height / 2
        imgAuthor.layer.masksToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
