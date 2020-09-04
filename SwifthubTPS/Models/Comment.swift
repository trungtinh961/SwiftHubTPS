//
//  Comment.swift
//  SwifthubTPS
//
//  Created by TPS on 9/4/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import Foundation

import ObjectMapper

struct Comment: Mappable {

    var authorAssociation: String?
    var body: String?
    var createdAt: Date?
    var htmlUrl: String?
    var id: Int?
    var issueUrl: String?
    var nodeId: String?
    var updatedAt: Date?
    var url: String?
    var user: User?
   
    init?(map: Map) {}
    init() {}

    mutating func mapping(map: Map) {
        authorAssociation <- map["author_association"]
        body <- map["body"]
        createdAt <- (map["created_at"], ISO8601DateTransform())
        htmlUrl <- map["html_url"]
        id <- map["id"]
        issueUrl <- map["issue_url"]
        nodeId <- map["node_id"]
        updatedAt <- (map["updated_at"], ISO8601DateTransform())
        url <- map["url"]
        user <- map["user"]
    }
}
