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
    case getIssues
    case getPullRequests
    case getCommits
    case getBranches
    case getReleases
    case getContributors
    case getRepositoryEvents
    case getUser
    case getStarred
    case getStargazers
    case getWatching
    case getWatchers
    case getUserEvents
    case getAuthenUser
    case getNotifications
}

enum Router {
    
    case getTrendingUser(language: String, since: TrendingSince)
    case getTrendingRepository(language: String, since: TrendingSince)
    case languages
    case searchRepositories(query: String, language: String)
    case searchUsers(query: String, language: String)
    case getRepository(fullname: String)
    case getIssues(fullname: String, issueState: IssueState)
    case getPullRequests(fullname: String, pullState: IssueState)
    case getCommits(fullname: String)
    case getBranches(fullname: String)
    case getReleases(fullname: String)
    case getContributors(fullname: String)
    case getEvents(fullname: String)
    case getUser(username: String)
    case getStarred(username: String)
    case getStargazers(fullname: String)
    case getWatching(username: String)
    case getWatchers(fullname: String)
    case getUserEvents(username: String, type: EventType)
    case getAuthenUser
    case getNotifications(notificationState: NotificationState)
    
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
        case .getIssues(let fullname, _): return "/repos/\(fullname)/issues"
        case .getPullRequests(let fullname, _): return "/repos/\(fullname)/pulls"
        case .getCommits(let fullname): return "/repos/\(fullname)/commits"
        case .getBranches(let fullname): return "/repos/\(fullname)/branches"
        case .getReleases(let fullname): return "/repos/\(fullname)/releases"
        case .getContributors(let fullname): return "/repos/\(fullname)/contributors"
        case .getEvents(let fullname): return "/repos/\(fullname)/events"
        case .getUser(let username): return "/users/\(username)"
        case .getStarred(let username): return "/users/\(username)/starred"
        case .getStargazers(let fullname): return "/repos/\(fullname)/stargazers"
        case .getWatching(let username): return "/users/\(username)/subscriptions"
        case .getWatchers(let fullname): return "/repos/\(fullname)/subscribers"
        case .getUserEvents(let username, let type): return "/users/\(username)/\(type.rawValue)"
        case .getAuthenUser: return "/user"
        case .getNotifications: return "/notifications"
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
            params["per_page"] = "50"
        case .searchUsers(let query, let language):
            if language != "" {
                params["q"] = "\(query)+language:\(language)"
            } else {
                params["q"] = query
            }
            params["per_page"] = "50"
        case .getIssues(_, let state),
             .getPullRequests(_, let state):
            params["state"] = state.rawValue
            params["per_page"] = "50"
        case .getCommits,
             .getBranches,
             .getReleases,
             .getContributors,
             .getEvents,
             .getStarred,
             .getStargazers,
             .getWatching,
             .getWatchers,
             .getUserEvents:
            params["per_page"] = "50"
        case .getNotifications(let notificationState):
            switch notificationState {
            case .unread: break
            case .participate: params["participating"] = "true"
            case .all: params["all"] = "false"
            }
            params["per_page"] = "50"
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
