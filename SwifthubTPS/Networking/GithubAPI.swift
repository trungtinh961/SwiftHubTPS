//
//  GithubAPI.swift
//  SwifthubTPS
//
//  Created by TPS on 8/31/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import Foundation
import ObjectMapper

class GitHubAPI<Element: Mappable> {
    
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    var errorMessage = ""
    var elements: [Element] = []
    
    typealias JSONDictionary = [String: Any]
    typealias QueryResults = ([Element]?, String, Int?) -> Void
    
    func createURL(type: GetType, eventType: EventType, gitHubAuthenticationManager: GITHUB, state: IssueState, notificationState: NotificationState,  query: String, language: String, fullname: String, username: String, number: Int, path: String) -> URL? {
        var components = URLComponents()
        switch type {
        case .repository:
            components.scheme = Router.searchRepositories(query: query, language: language).scheme
            components.host = Router.searchRepositories(query: query, language: language).host
            components.path = Router.searchRepositories(query: query, language: language).path
            components.setQueryItems(with: Router.searchRepositories(query: query, language: language).parameters!)
        case .user:
            components.scheme = Router.searchUsers(query: query, language: language).scheme
            components.host = Router.searchUsers(query: query, language: language).host
            components.path = Router.searchUsers(query: query, language: language).path
            components.setQueryItems(with: Router.searchUsers(query: query, language: language).parameters!)
        case .language:
            break
        case .getRepository:
            components.scheme = Router.getRepository(fullname: fullname).scheme
            components.host = Router.getRepository(fullname: fullname).host
            components.path = Router.getRepository(fullname: fullname).path
        case .getForks:
            components.scheme = Router.getForks(fullname: fullname).scheme
            components.host = Router.getForks(fullname: fullname).host
            components.path = Router.getForks(fullname: fullname).path
            components.setQueryItems(with: Router.getForks(fullname: fullname).parameters!)
        case .getIssues:
            components.scheme = Router.getIssues(fullname: fullname, issueState: state).scheme
            components.host = Router.getIssues(fullname: fullname, issueState: state).host
            components.path = Router.getIssues(fullname: fullname, issueState: state).path
            components.setQueryItems(with: Router.getIssues(fullname: fullname, issueState: state).parameters!)
        case .getPullRequests:
            components.scheme = Router.getPullRequests(fullname: fullname, pullState: state).scheme
            components.host = Router.getPullRequests(fullname: fullname, pullState: state).host
            components.path = Router.getPullRequests(fullname: fullname, pullState: state).path
            components.setQueryItems(with: Router.getPullRequests(fullname: fullname, pullState: state).parameters!)
        case .getCommits:
            components.scheme = Router.getCommits(fullname: fullname).scheme
            components.host = Router.getCommits(fullname: fullname).host
            components.path = Router.getCommits(fullname: fullname).path
            components.setQueryItems(with: Router.getCommits(fullname: fullname).parameters!)
        case .getBranches:
            components.scheme = Router.getBranches(fullname: fullname).scheme
            components.host = Router.getBranches(fullname: fullname).host
            components.path = Router.getBranches(fullname: fullname).path
            components.setQueryItems(with: Router.getBranches(fullname: fullname).parameters!)
        case .getReleases:
            components.scheme = Router.getReleases(fullname: fullname).scheme
            components.host = Router.getReleases(fullname: fullname).host
            components.path = Router.getReleases(fullname: fullname).path
            components.setQueryItems(with: Router.getReleases(fullname: fullname).parameters!)
        case .getContributors:
            components.scheme = Router.getContributors(fullname: fullname).scheme
            components.host = Router.getContributors(fullname: fullname).host
            components.path = Router.getContributors(fullname: fullname).path
            components.setQueryItems(with: Router.getContributors(fullname: fullname).parameters!)
        case .getRepositoryEvents:
            components.scheme = Router.getEvents(fullname: fullname).scheme
            components.host = Router.getEvents(fullname: fullname).host
            components.path = Router.getEvents(fullname: fullname).path
            components.setQueryItems(with: Router.getEvents(fullname: fullname).parameters!)
        case .getUser:
            components.scheme = Router.getUser(username: username).scheme
            components.host = Router.getUser(username: username).host
            components.path = Router.getUser(username: username).path
        case .getStarred:
            components.scheme = Router.getStarred(username: username).scheme
            components.host = Router.getStarred(username: username).host
            components.path = Router.getStarred(username: username).path
            components.setQueryItems(with: Router.getStarred(username: username).parameters!)
        case .getStargazers:
            components.scheme = Router.getStargazers(fullname: fullname).scheme
            components.host = Router.getStargazers(fullname: fullname).host
            components.path = Router.getStargazers(fullname: fullname).path
            components.setQueryItems(with: Router.getStargazers(fullname: fullname).parameters!)
        case .getWatching:
            components.scheme = Router.getWatching(username: username).scheme
            components.host = Router.getWatching(username: username).host
            components.path = Router.getWatching(username: username).path
            components.setQueryItems(with: Router.getWatching(username: username).parameters!)
        case .getWatchers:
            components.scheme = Router.getWatchers(fullname: fullname).scheme
            components.host = Router.getWatchers(fullname: fullname).host
            components.path = Router.getWatchers(fullname: fullname).path
            components.setQueryItems(with: Router.getWatchers(fullname: fullname).parameters!)
        case .getUserEvents:
            components.scheme = Router.getUserEvents(username: username, type: eventType).scheme
            components.host = Router.getUserEvents(username: username, type: eventType).host
            components.path = Router.getUserEvents(username: username, type: eventType).path
            components.setQueryItems(with: Router.getUserEvents(username: username, type: eventType).parameters!)
        case .getAuthenUser:
            components.scheme = Router.getAuthenUser.scheme
            components.host = Router.getAuthenUser.host
            components.path = Router.getAuthenUser.path
        case .getRepositoryOfAuthenUser:
            components.scheme = Router.getRepositoryOfAuthenUser.scheme
            components.host = Router.getRepositoryOfAuthenUser.host
            components.path = Router.getRepositoryOfAuthenUser.path
            components.setQueryItems(with: Router.getRepositoryOfAuthenUser.parameters!)
        case .getNotifications, .makeNotificationAllRead:
            components.scheme = Router.getNotifications(notificationState: notificationState).scheme
            components.host = Router.getNotifications(notificationState: notificationState).host
            components.path = Router.getNotifications(notificationState: notificationState).path
            if type == .getNotifications {
                components.setQueryItems(with: Router.getNotifications(notificationState: notificationState).parameters!)
            }            
        case .getUserRepositories:
            components.scheme = Router.getUserRepositories(username: username).scheme
            components.host = Router.getUserRepositories(username: username).host
            components.path = Router.getUserRepositories(username: username).path
            components.setQueryItems(with: Router.getUserRepositories(username: username).parameters!)
        case .getFollowers:
            components.scheme = Router.getFollowers(username: username).scheme
            components.host = Router.getFollowers(username: username).host
            components.path = Router.getFollowers(username: username).path
            components.setQueryItems(with: Router.getFollowers(username: username).parameters!)
        case .getFollowing:
            components.scheme = Router.getFollowing(username: username).scheme
            components.host = Router.getFollowing(username: username).host
            components.path = Router.getFollowing(username: username).path
            components.setQueryItems(with: Router.getFollowing(username: username).parameters!)
        case .followUser, .unFollowUser, .checkFollowedUser:
            components.scheme = Router.followUser(username: username).scheme
            components.host = Router.followUser(username: username).host
            components.path = Router.followUser(username: username).path
        case .starRepository, .unStarRepository, .checkStarredRepository:
            components.scheme = Router.starRepository(fullname: fullname).scheme
            components.host = Router.starRepository(fullname: fullname).host
            components.path = Router.starRepository(fullname: fullname).path
        case .getIssueComments, .createIssueComment:
            components.scheme = Router.getIssueComment(fullname: fullname, number: String(number)).scheme
            components.host = Router.getIssueComment(fullname: fullname, number: String(number)).host
            components.path = Router.getIssueComment(fullname: fullname, number: String(number)).path
            if type == .getIssueComments {
                components.setQueryItems(with: Router.getIssueComment(fullname: fullname, number: String(number)).parameters!)
            }
        case .getOrganizations:
            components.scheme = Router.getOrganizations(username: username).scheme
            components.host = Router.getOrganizations(username: username).host
            components.path = Router.getOrganizations(username: username).path
            components.setQueryItems(with: Router.getOrganizations(username: username).parameters!)
        case .getContents, .getContent:
            components.scheme = Router.getContents(fullname: fullname, path: path).scheme
            components.host = Router.getContents(fullname: fullname, path: path).host
            components.path = Router.getContents(fullname: fullname, path: path).path
        }
        
        components.percentEncodedQuery = components.percentEncodedQuery?.removingPercentEncoding
        return components.url
    }
    
    
    func getResults(type: GetType, eventType: EventType = .received, gitHubAuthenticationManager: GITHUB, state: IssueState = .open, notificationState: NotificationState = .unread, query: String = "", language: String = "", fullname: String = "", username: String = "", number: Int = 0, body: String = "", path: String = "", completion: @escaping QueryResults) {
        
        dataTask?.cancel()
        
        guard let url = createURL(type: type, eventType: eventType, gitHubAuthenticationManager: gitHubAuthenticationManager, state: state, notificationState: notificationState, query: query, language: language, fullname: fullname, username: username, number: number, path: path)
            else {
                return
            }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = { () -> String in
            switch type {
            case .createIssueComment: return "POST"
            case .followUser, .starRepository, .makeNotificationAllRead: return "PUT"
            case .unFollowUser, .unStarRepository: return "DELETE"
            default:
                return "GET"
            }
        }()
        
        if type == .createIssueComment {
            let json: [String: Any] = ["body": body]
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            request.httpBody = jsonData
        }
        
        if type == .getContents {
            request.setValue("application/vnd.github.v3.raw", forHTTPHeaderField: "Accept")
        } else {
            request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        }
        
        if gitHubAuthenticationManager.didAuthenticated {
            request.setValue("token \(gitHubAuthenticationManager.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        }
        
        debugPrint("\(request.httpMethod ?? ""): \(request)")
        
        dataTask = defaultSession.dataTask(with: request) { [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }
            if let error = error, let response = response as? HTTPURLResponse {
                DispatchQueue.main.async {
                    completion([], self?.errorMessage ?? "", response.statusCode)
                }
                self?.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == StatusCode.OK || response.statusCode == StatusCode.CREATE {
                    self?.updateSearchResults(type: type, data)
                    DispatchQueue.main.async {
                        completion(self?.elements, self?.errorMessage ?? "", response.statusCode)
                    }
            } else if
                let response = response as? HTTPURLResponse {
                DispatchQueue.main.async {
                    completion([], self?.errorMessage ?? "", response.statusCode)
                }
            }
        }
        dataTask?.resume()
    }
        
      
    private func updateSearchResults(type: GetType, _ data: Data) {
        elements.removeAll()
        var jsonArray: Array<Any>!
        switch type {
        case .getRepository, .getUser, .repository, .user, .getAuthenUser, .createIssueComment, .getContent: /// Json return 1 element
            do {
                if let item = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String: AnyObject] {
                    elements.append(Element(JSON: item)!)
                }
            } catch {
                errorMessage += "JSONSerialization error: \(error.localizedDescription)\n"
                return
            }
            
        default: /// Json return array
            do {
                jsonArray = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? Array
            } catch {
                errorMessage += "JSONSerialization error: \(error.localizedDescription)\n"
                return
            }
            for json in jsonArray {
              if let item = json as? [String: AnyObject] {
                elements.append(Element(JSON: item)!)
              }
            }
        }
        
    }
    
}
