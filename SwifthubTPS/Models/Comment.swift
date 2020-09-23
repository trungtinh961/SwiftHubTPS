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
    var body: String?
    var createdAt: Date?
    var id: Int?
    var updatedAt: Date?
    var user: User?
    
    // MessageType
    var sender: SenderType { return user ?? User() }
    var messageId: String { return String(describing: id) }
    var sentDate: Date { return createdAt ?? Date() }
    var kind: MessageKind { return .text(body ?? "") }
   
    init?(map: Map) {}
    init() {}

    mutating func mapping(map: Map) {
        body <- map["body"]
        createdAt <- (map["created_at"], ISO8601DateTransform())
        id <- map["id"]
        updatedAt <- (map["updated_at"], ISO8601DateTransform())
        user <- map["user"]
    }
}
