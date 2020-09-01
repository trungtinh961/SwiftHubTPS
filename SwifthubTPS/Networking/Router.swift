//
//  RouterCase.swift
//  SwifthubTPS
//
//  Created by TPS on 8/27/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import Foundation

enum GetType: Int {
    case repository
    case user
    case language
    case getRepository
}

enum Router {
    
    case getTrendingUser(language: String, since: TrendingSince)
    case getTrendingRepository(language: String, since: TrendingSince)
    case languages
    case searchRepositories(query: String, language: String)
    case searchUsers(query: String, language: String)
    case getRepository(fullname: String)
    
    
    var scheme: String {
        switch self {
        default: return "https"
        }
    }
    
    var host: String {
        switch self {
        case .getTrendingRepository, .getTrendingUser, .languages: return "ghapi.huchen.dev"
        default: return "api.github.com"
        }
        
    }
 
    var path: String {
        switch self {
        case .getTrendingRepository: return "/repositories"
        case .getTrendingUser: return "/developers"
        case .languages: return "/languages"
        case .searchRepositories: return "/search/repositories"
        case .searchUsers: return "/search/users"
        case .getRepository(let fullname): return "/repos/\(fullname)"
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
        case .searchRepositories(let query, let language):
            if language != "" {
                params["q"] = "\(query)+language:\(language)"
            } else {
                params["q"] = query
            }            
            params["sort"] = "stars"
            params["order"] = "desc"
        case .searchUsers(let query, let language):
            if language != "" {
                params["q"] = "\(query)+language:\(language)"
            } else {
                params["q"] = query
            }   
        default: break
        }
        return params
    }    
    
    var method: String {
        switch self {
        default:
            return "GET"
        }
    }
    
}
