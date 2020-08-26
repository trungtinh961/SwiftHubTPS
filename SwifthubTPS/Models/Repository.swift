//
//  Repository.swift
//  SwifthubTPS
//
//  Created by TPS on 8/26/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import Foundation
import ObjectMapper

struct TrendingRepository: Mappable {
        
    var author: String?
    var name: String?
    var url: String?
    var description: String?
    var language: String?
    var languageColor: String?
    var stars: Int?
    var forks: Int?
    var currentPeriodStars: Int?
    var builtBy: [TrendingUser]?
    
    var fullname: String? {
        return "\(author ?? "")/\(name ?? "")"
    }
    
    var avatarUrl: String? {
        return builtBy?.first?.avatar
    }
    
    init() {}
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        author <- map["author"]
        name <- map["name"]
        url <- map["url"]
        description <- map["description"]
        language <- map["language"]
        languageColor <- map["languageColor"]
        stars <- map["stars"]
        forks <- map["forks"]
        currentPeriodStars <- map["currentPeriodStars"]
        builtBy <- map["builtBy"]
    }
}




