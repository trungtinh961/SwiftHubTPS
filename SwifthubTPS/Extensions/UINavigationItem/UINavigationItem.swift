//
//  UINavigationItem.swift
//  SwifthubTPS
//
//  Created by TPS on 9/3/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import UIKit

extension UINavigationItem {
    func setTitle(title:String, subtitle:String) {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: -2, width: 0, height: 0))

        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont.boldSystemFont(ofSize: 13)
            titleLabel.text = title
            titleLabel.sizeToFit()

        let subtitleLabel = UILabel(frame: CGRect(x: 0, y: 18, width: 0, height: 0))
        subtitleLabel.backgroundColor = UIColor.clear
        subtitleLabel.textColor = UIColor.gray
        subtitleLabel.font = UIFont.systemFont(ofSize: 17)
            subtitleLabel.text = subtitle
            subtitleLabel.sizeToFit()

        let stackView = UIView(frame: CGRect(x: 0, y: 0, width: max(titleLabel.frame.size.width, subtitleLabel.frame.size.width), height: 30))
            stackView.addSubview(titleLabel)
            stackView.addSubview(subtitleLabel)

            let widthDiff = subtitleLabel.frame.size.width - titleLabel.frame.size.width

            if widthDiff < 0 {
                let newX = widthDiff / 2
                subtitleLabel.frame.origin.x = abs(newX)
            } else {
                let newX = widthDiff / 2
                titleLabel.frame.origin.x = newX
            }

        self.titleView = stackView
    }
}
