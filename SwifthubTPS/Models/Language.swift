//
//  Language.swift
//  SwifthubTPS
//
//  Created by TPS on 8/28/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import Foundation
import ObjectMapper

struct Language: Mappable {
    
    var urlParam: String?
    var name: String?
    
    init?(map: Map) {}
    
    init() {}
    
    mutating func mapping(map: Map) {
        urlParam <- map["urlParam"]
        name <- map["name"]        
    }
    
}

extension Language: Equatable {
    
    static func == (lhs: Language, rhs: Language) -> Bool {
        return lhs.urlParam == rhs.urlParam
    }
    
}
