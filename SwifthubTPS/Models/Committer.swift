//
//  Committer.swift
//  SwifthubTPS
//
//  Created by TPS on 9/4/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import Foundation
import ObjectMapper

struct Committer: Mappable {

    var name: String?
    var email: String?
    var date: Date?

    init?(map: Map) {}
    init() {}

    mutating func mapping(map: Map) {
        name <- map["name"]
        email <- map["email"]
        date <- (map["date"], ISO8601DateTransform())
    }
}
