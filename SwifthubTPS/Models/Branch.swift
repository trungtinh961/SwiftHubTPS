//
//  Branch.swift
//  SwifthubTPS
//
//  Created by TPS on 9/4/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import Foundation
import ObjectMapper

struct Branch: Mappable {

    var commit: Commit?
    var name: String?

    init?(map: Map) {}
    init() {}

    mutating func mapping(map: Map) {
        commit <- map["commit"]
        name <- map["name"]
    }
}
