//
//  IssueCell.swift
//  SwifthubTPS
//
//  Created by TPS on 9/3/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import UIKit

class IssueCell: UITableViewCell {
    
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var imgAuthor: UIImageView!
    @IBOutlet weak var imgState: UIImageView!
    @IBOutlet weak var imgDisclosure: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbDescription: UILabel!
    @IBOutlet weak var lbCommentCount: UILabel!
    @IBOutlet weak var lbTag1: UILabel!
    @IBOutlet weak var lbTag2: UILabel!
    @IBOutlet weak var lbTag3: UILabel!
    @IBOutlet weak var lbTag4: UILabel!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        mainView.layer.cornerRadius = 5
        imgState.layer.masksToBounds = true
        imgState.layer.cornerRadius = imgState.frame.width / 2
        imgAuthor.layer.masksToBounds = true
        imgAuthor.layer.cornerRadius = imgAuthor.frame.width / 2
        lbTag1.isHidden = true
        lbTag1.sizeToFit()
        lbTag2.isHidden = true
        lbTag2.sizeToFit()
        lbTag3.isHidden = true
        lbTag3.sizeToFit()
        lbTag4.isHidden = true
        lbTag4.sizeToFit()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
}
