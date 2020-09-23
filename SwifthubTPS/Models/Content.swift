//
//  Content.swift
//  SwifthubTPS
//
//  Created by TPS on 9/15/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import Foundation
import ObjectMapper

enum ContentType: String {
    case file = "file"
    case dir = "dir"
    case symlink = "symlink"
    case submodule = "submodule"
    case unknown = ""
}

extension ContentType: Comparable {
    func priority() -> Int {
        switch self {
        case .file: return 0
        case .dir: return 1
        case .symlink: return 2
        case .submodule: return 3
        case .unknown: return 4
        }
    }

    static func < (lhs: ContentType, rhs: ContentType) -> Bool {
        return lhs.priority() < rhs.priority()
    }
}

struct Content: Mappable {
    
    var name: String?
    var path: String?
    var size: Int?
    var type: ContentType = .unknown

    init?(map: Map) {}
    init() {}

    mutating func mapping(map: Map) {
        name <- map["name"]
        path <- map["path"]
        size <- map["size"]
        type <- map["type"]
    }
}

