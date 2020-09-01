//
//  Foundation.swift
//  SwifthubTPS
//
//  Created by TPS on 8/27/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import Foundation

extension Int {

    func sizeFromKB() -> String {
        return (self*1024).sizeFromByte()
    }

    func sizeFromByte() -> String {
        return ByteCountFormatter.string(fromByteCount: Int64(self), countStyle: .file)
    }

    func kFormatted() -> String {
        let sign = ((self < 0) ? "-" : "" )
        if self < 1000 {
            return "\(sign)\(self)"
        }
        let num = fabs(Double(self))
        let exp: Int = Int(log10(num) / 3.0 ) //log10(1000))
        let units: [String] = ["K", "M", "G", "T", "P", "E"]
        let roundedNum: Double = round(10 * num / pow(1000.0, Double(exp))) / 10
        return "\(sign)\(roundedNum)\(units[exp-1])"
    }
}

extension URLComponents {
    
    mutating func setQueryItems(with parameters: [String: String]) {
        self.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
    }
    
    
}

