//
//  RouterCase.swift
//  SwifthubTPS
//
//  Created by TPS on 8/27/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import Foundation

enum Router {
    
    case getTrendingUser(language: String, since: TrendingSince)
    case getTrendingRepository(language: String, since: TrendingSince)
    case languages
    
    var scheme: String {
        switch self {
        case .getTrendingUser, .getTrendingRepository, .languages: return "https"
        }
    }
    
    var host: String {
        switch self {
        case .getTrendingRepository, .getTrendingUser, .languages: return "ghapi.huchen.dev"
        }
        
    }
 
    var path: String {
        switch self {
            case .getTrendingRepository: return "/repositories"
            case .getTrendingUser: return "/developers"
            case .languages: return "/languages"
        }
    }
    
    var parameters: [String: String]? {
        var params: [String: String] = [:]
        switch self {
        case .getTrendingRepository(let language, let since),
             .getTrendingUser(let language, let since):
            if language != "" {
                params["language"] = language
            }
            params["since"] = since.rawValue
        default: break
        }
        return params
    }    
    
    var method: String {
        switch self {
        case .getTrendingRepository, .getTrendingUser, .languages:
            return "GET"
        
        }
    }
    
}
