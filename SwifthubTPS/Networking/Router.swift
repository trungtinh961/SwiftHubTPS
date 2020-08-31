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
    case searchReposytoryGithub(searchText: String, language: String)
    
    var scheme: String {
        switch self {
        case .getTrendingUser, .getTrendingRepository, .languages, .searchReposytoryGithub: return "https"
        }
    }
    
    var host: String {
        switch self {
        case .getTrendingRepository, .getTrendingUser, .languages: return "ghapi.huchen.dev"
        case .searchReposytoryGithub: return "api.github.com"
        }
        
    }
 
    var path: String {
        switch self {
        case .getTrendingRepository: return "/repositories"
        case .getTrendingUser: return "/developers"
        case .languages: return "/languages"
        case .searchReposytoryGithub: return "/search/repositories"
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
        case .searchReposytoryGithub(let searchText, let language):
            if language != "" {
                params["language"] = language
            }
            params["q"] = searchText
            params["sort"] = "stars"
            params["order"] = "desc"
        default: break
        }
        return params
    }    
    
    var method: String {
        switch self {
        case .getTrendingRepository, .getTrendingUser, .languages, .searchReposytoryGithub:
            return "GET"        
        }
    }
    
}
