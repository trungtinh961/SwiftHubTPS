//
//  Commit.swift
//  SwifthubTPS
//
//  Created by TPS on 9/4/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import Foundation
import ObjectMapper

struct Commit: Mappable {
    var commit: CommitInfo?
    var htmlUrl: String?
    var sha: String?
    var author: User?

    init?(map: Map) {}
    init() {}

    mutating func mapping(map: Map) {
        commit <- map["commit"]
        htmlUrl <- map["html_url"]
        sha <- map["sha"]
        author <- map["author"]
    }
}

struct CommitInfo: Mappable {
    
    var author: Committer?
    var message: String?

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        author <- map["author"]
        message <- map["message"]
    }
}
