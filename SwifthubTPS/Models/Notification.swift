//
//  Notification.swift
//  SwifthubTPS
//
//  Created by TPS on 9/9/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import Foundation
import ObjectMapper

struct Notification: Mappable {

    var id: String?
    var lastReadAt: Date?
    var reason: String?
    var repository: Repository?
    var subject: Subject?
    var subscriptionUrl: String?
    var unread: Bool?
    var updatedAt: Date?
    var url: String?

    init?(map: Map) {}
    init() {}

    mutating func mapping(map: Map) {
        id <- map["id"]
        lastReadAt <- (map["last_read_at"], ISO8601DateTransform())
        reason <- map["reason"]
        repository <- map["repository"]
        subject <- map["subject"]
        subscriptionUrl <- map["subscription_url"]
        unread <- map["unread"]
        updatedAt <- (map["updated_at"], ISO8601DateTransform())
        url <- map["url"]
    }
}

extension Notification: Equatable {
    static func == (lhs: Notification, rhs: Notification) -> Bool {
        return lhs.id == rhs.id
    }
}

struct Subject: Mappable {

    var latestCommentUrl: String?
    var title: String?
    var type: String?
    var url: String?

    init?(map: Map) {}
    init() {}

    mutating func mapping(map: Map) {
        latestCommentUrl <- map["latest_comment_url"]
        title <- map["title"]
        type <- map["type"]
        url <- map["url"]
    }
}
