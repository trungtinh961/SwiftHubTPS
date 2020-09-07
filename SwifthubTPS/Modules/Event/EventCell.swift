//
//  EventCell.swift
//  SwifthubTPS
//
//  Created by TPS on 9/4/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import UIKit

class EventCell: UITableViewCell {

    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var imgAuthor: UIImageView!
    @IBOutlet weak var imgDisclosure: UIImageView!
    @IBOutlet weak var imgState: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var lbDetail: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        mainView.layer.cornerRadius = 5
//        imgDisclosure.isHidden = true
        imgAuthor.layer.masksToBounds = true
        imgAuthor.layer.cornerRadius = imgAuthor.frame.width / 2
        imgState.layer.masksToBounds = true
        imgState.layer.cornerRadius = imgState.frame.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
       
    }
    
    
    
}
