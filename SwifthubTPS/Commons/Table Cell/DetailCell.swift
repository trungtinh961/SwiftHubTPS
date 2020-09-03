//
//  DetailCell.swift
//  SwifthubTPS
//
//  Created by TPS on 9/1/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import UIKit

class DetailCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var imgCell: UIImageView!
    @IBOutlet weak var lbTitleCell: UILabel!
    @IBOutlet weak var lbDetails: UILabel!
    @IBOutlet weak var imgDisclosure: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        mainView.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}

struct DetailCellProperty {
    var imgName: String
    var titleCell: String
    var detail: String = ""
    var hideDisclosure: Bool
}
