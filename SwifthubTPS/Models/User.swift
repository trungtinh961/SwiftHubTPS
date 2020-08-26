//
//  User.swift
//  SwifthubTPS
//
//  Created by TPS on 8/26/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import Foundation
import ObjectMapper

enum TrendingUserType: String {
    case user
    case organization
}

struct TrendingUser: Mappable {
       
    var username: String?
    var name: String?
    var url: String?
    var avatar: String?
    var repo: TrendingRepository?
    var type: TrendingUserType = .user
    
    init?(map: Map) {}
    
    init() {}
    
    mutating func mapping(map: Map) {
        username <- map["username"]
        name <- map["name"]
        url <- map["url"]
        avatar <- map["avatar"]
        repo <- map["repo"]
        type <- map["type"]
        repo?.author = username
    }
    
}
