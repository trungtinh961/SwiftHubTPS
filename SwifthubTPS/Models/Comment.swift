//
//  Comment.swift
//  SwifthubTPS
//
//  Created by TPS on 9/4/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import Foundation
import ObjectMapper
import MessageKit

struct Comment: Mappable, MessageType {

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
    
    // MessageType
    var sender: SenderType { return user ?? User() }
    var messageId: String { return String(describing: id) }
    var sentDate: Date { return createdAt ?? Date() }
    var kind: MessageKind { return .text(body ?? "") }
   
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
