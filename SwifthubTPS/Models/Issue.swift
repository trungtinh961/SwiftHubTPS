//
//  Issue.swift
//  SwifthubTPS
//
//  Created by TPS on 9/3/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import Foundation
import MessageKit
import ObjectMapper

struct Issue: Mappable, MessageType {
    
    var body: String?
    var comments: Int?
    var createdAt: Date?
    var id: Int?
    var labels: [IssueLabel]?
    var number: Int?
    var state: IssueState = .open
    var title: String?
    var user: User?

    init?(map: Map) {}
    init() {}

    mutating func mapping(map: Map) {
        body <- map["body"]
        comments <- map["comments"]
        createdAt <- (map["created_at"], ISO8601DateTransform())
        id <- map["id"]
        labels <- map["labels"]
        number <- map["number"]
        state <- map["state"]
        title <- map["title"]
        user <- map["user"]
    }
    
    // MessageType
    var sender: SenderType { return user ?? User() }
    var messageId: String { return String(describing: id) }
    var sentDate: Date { return createdAt ?? Date() }
    var kind: MessageKind { return .text(body ?? "") }
    
}

struct IssueLabel: Mappable {
    
    var color: String?
    var name: String?

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        color <- map["color"]
        name <- map["name"]
    }
}

