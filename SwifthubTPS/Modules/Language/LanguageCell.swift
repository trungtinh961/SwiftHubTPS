//
//  LanguageCell.swift
//  SwifthubTPS
//
//  Created by TPS on 8/28/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import UIKit

class LanguageCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var lbLanguage: UILabel!
    @IBOutlet weak var imgCheck: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        mainView.layer.cornerRadius = 5
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}