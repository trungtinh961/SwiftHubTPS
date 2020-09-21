//
//  RouterCase.swift
//  SwifthubTPS
//
//  Created by TPS on 8/27/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import Foundation

enum GetType: Int {
    /// Search
    case repository
    case user
    case language
    /// Repository
    case getRepository
    case getForks
    case getIssues
    case getPullRequests
    case getCommits
    case getBranches
    case getReleases
    case getContributors
    case getRepositoryEvents
    case getStargazers
    case getWatchers
    case getContents
    case getRepositoryLanguage
    /// User
    case getUser
    case getStarred
    case getWatching
    case getUserEvents
    case getFollowers
    case getFollowing
    case getOrganizations
    case getUserRepositories
    /// Authentication require
    case getAuthenUser
    case getRepositoryOfAuthenUser
    case getNotifications
    case makeNotificationAllRead
    case followUser
    case unFollowUser
    case checkFollowedUser
    case starRepository
    case unStarRepository
    case checkStarredRepository
    case getIssueComments
    case createIssueComment
}

enum Router {
    /// Use trending-github-api
    case getTrendingUser(language: String, since: TrendingSince)
    case getTrendingRepository(language: String, since: TrendingSince)
    case languages
    /// Use github-api
    case searchRepositories(query: String, language: String)
    case searchUsers(query: String, language: String)
    /// Repository
    case getRepository(fullname: String)
    case getForks(fullname: String)
    case getIssues(fullname: String, issueState: IssueState)
    case getPullRequests(fullname: String, pullState: IssueState)
    case getCommits(fullname: String)
    case getBranches(fullname: String)
    case getReleases(fullname: String)
    case getContributors(fullname: String)
    case getRepositoryEvents(fullname: String)
    case getStargazers(fullname: String)
    case getWatchers(fullname: String)
    case getContents(fullname: String, path: String)
    case getRepositoryLanguage(fullname: String)
    /// User
    case getUser(username: String)
    case getStarred(username: String)
    case getWatching(username: String)
    case getUserEvents(username: String, type: EventType)
    case getFollowers(username: String)
    case getFollowing(username: String)
    case getOrganizations(username: String)
    case getUserRepositories(username: String)
    /// Authentication require
    case getAuthenUser
    case getRepositoryOfAuthenUser
    case getNotifications(notificationState: NotificationState)
    case makeNotificationAllRead
    case followUser(username: String)
    case unFollowUser(username: String)
    case checkFollowedUser(username: String)
    case starRepository(fullname: String)
    case unStarRepository(fullname: String)
    case checkStarredRepository(fullname: String)
    case getIssueComment(fullname: String, number: String)
    case createIssueComment(fullname: String, number: String)
        
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
        /// Use trending-github-api
        case .getTrendingRepository: return "/repositories"
        case .getTrendingUser: return "/developers"
        case .languages: return "/languages"
        /// Use github-api
        case .searchRepositories: return "/search/repositories"
        case .searchUsers: return "/search/users"
        /// Repository
        case .getRepository(let fullname): return "/repos/\(fullname)"
        case .getForks(let fullname): return "/repos/\(fullname)/forks"
        case .getIssues(let fullname, _): return "/repos/\(fullname)/issues"
        case .getPullRequests(let fullname, _): return "/repos/\(fullname)/pulls"
        case .getCommits(let fullname): return "/repos/\(fullname)/commits"
        case .getBranches(let fullname): return "/repos/\(fullname)/branches"
        case .getReleases(let fullname): return "/repos/\(fullname)/releases"
        case .getContributors(let fullname): return "/repos/\(fullname)/contributors"
        case .getRepositoryEvents(let fullname): return "/repos/\(fullname)/events"
        case .getStargazers(let fullname): return "/repos/\(fullname)/stargazers"
        case .getWatchers(let fullname): return "/repos/\(fullname)/subscribers"
        case .getContents(let fullname, let path): return "/repos/\(fullname)/contents/\(path)"
        case .getRepositoryLanguage(let fullname): return "/repos/\(fullname)/languages"
        /// User
        case .getUser(let username): return "/users/\(username)"
        case .getStarred(let username): return "/users/\(username)/starred"
        case .getWatching(let username): return "/users/\(username)/subscriptions"
        case .getUserEvents(let username, let type): return "/users/\(username)/\(type.rawValue)"
        case .getFollowers(let username): return "/users/\(username)/followers"
        case .getFollowing(let username): return "/users/\(username)/following"
        case .getOrganizations(let username): return "/users/\(username)/orgs"
        case .getUserRepositories(let username): return "/users/\(username)/repos"
        /// Authentication require
        case .getAuthenUser: return "/user"
        case .getRepositoryOfAuthenUser: return "/user/repos"
        case .getNotifications,
             .makeNotificationAllRead:
            return "/notifications"
        
        case .followUser(let username),
             .unFollowUser(let username),
             .checkFollowedUser(let username):
            return "/user/following/\(username)"
        case .starRepository(let fullname),
             .unStarRepository(let fullname),
             .checkStarredRepository(let fullname):
            return "/user/starred/\(fullname)"
        case .getIssueComment(let fullname, let number): return "/repos/\(fullname)/issues/\(number)/comments"
        case .createIssueComment(let fullname, let number): return "/repos/\(fullname)/issues/\(number)/comments"
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
            params["per_page"] = "100"
        case .searchUsers(let query, let language):
            if language != "" {
                params["q"] = "\(query)+language:\(language)"
            } else {
                params["q"] = query
            }
            params["per_page"] = "100"
        case .getIssues(_, let state),
             .getPullRequests(_, let state):
            params["state"] = state.rawValue
            params["per_page"] = "100"
        case .getCommits,
             .getBranches,
             .getReleases,
             .getContributors,
             .getRepositoryEvents,
             .getForks,
             .getStarred,
             .getStargazers,
             .getWatching,
             .getWatchers,
             .getFollowers,
             .getFollowing,
             .getUserEvents,
             .getIssueComment,
             .getUserRepositories,
             .getOrganizations:
            params["per_page"] = "100"
        case .getNotifications(let notificationState):
            switch notificationState {
            case .unread: break
            case .participate: params["participating"] = "true"
            case .all: params["all"] = "true"
            }
            params["per_page"] = "100"
        case .getRepositoryOfAuthenUser:
            params["visibility"] = "all"
            params["per_page"] = "100"
        default: break
        }
        return params
    }    
    
    var method: String {
        switch self {
        case .createIssueComment: return "POST"
        case .followUser, .starRepository, .makeNotificationAllRead: return "PUT"
        case .unFollowUser, .unStarRepository: return "DELETE"
        default:
            return "GET"
        }
    }
    
}
