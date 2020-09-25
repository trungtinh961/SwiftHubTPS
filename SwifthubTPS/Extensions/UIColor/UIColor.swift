//
//  UIColor.swift
//  SwifthubTPS
//
//  Created by TPS on 9/14/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import UIKit

extension UIColor {
    static let primaryColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
    static let backgroundColor = UIColor("#F5F5F5")
    
    static var random: UIColor {
        let red = Int.random(in: 0...255)
        let green = Int.random(in: 0...255)
        let blue = Int.random(in: 0...255)
        return UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 0.2)
    }
}

