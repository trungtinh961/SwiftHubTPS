//
//  Release.swift
//  SwifthubTPS
//
//  Created by TPS on 9/4/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import Foundation
import ObjectMapper

struct Release: Mappable {
    
    var author: User?
    var body: String?
    var createdAt: Date?
    var htmlUrl: String?
    var name: String?
    var tagName: String?

    init?(map: Map) {}
    init() {}

    mutating func mapping(map: Map) {
        author <- map["author"]
        body <- map["body"]
        createdAt <- (map["created_at"], ISO8601DateTransform())
        htmlUrl <- map["html_url"]
        name <- map["name"]
        tagName <- map["tag_name"]
    }
}
