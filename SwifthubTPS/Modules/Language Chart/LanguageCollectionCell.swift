//
//  LanguageCollectionCell.swift
//  SwifthubTPS
//
//  Created by TPS on 9/16/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import UIKit

class LanguageCollectionCell: UICollectionViewCell {

    @IBOutlet weak var languageColorView: UIView!
    @IBOutlet weak var lbLanguageName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        languageColorView.layer.cornerRadius = 3
    }

}
