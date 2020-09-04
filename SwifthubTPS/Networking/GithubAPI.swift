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
    typealias QueryResults = ([Element]?, String) -> Void
    
    func createURL(type: GetType, state: State, query: String, language: String, fullname: String, username: String) -> URL? {
        var components = URLComponents()
        
        if type == .repository {
            components.scheme = Router.searchRepositories(query: query, language: language).scheme
            components.host = Router.searchRepositories(query: query, language: language).host
            components.path = Router.searchRepositories(query: query, language: language).path
            components.setQueryItems(with: Router.searchRepositories(query: query, language: language).parameters!)
        } else if type == .user {
            components.scheme = Router.searchUsers(query: query, language: language).scheme
            components.host = Router.searchUsers(query: query, language: language).host
            components.path = Router.searchUsers(query: query, language: language).path
            components.setQueryItems(with: Router.searchUsers(query: query, language: language).parameters!)
        } else if type == .getRepository {
            components.scheme = Router.getRepository(fullname: fullname).scheme
            components.host = Router.getRepository(fullname: fullname).host
            components.path = Router.getRepository(fullname: fullname).path
        } else if type == .getUser {
            components.scheme = Router.getUser(username: username).scheme
            components.host = Router.getUser(username: username).host
            components.path = Router.getUser(username: username).path
        } else if type == .getIssues {
            components.scheme = Router.getIssues(fullname: fullname, state: state).scheme
            components.host = Router.getIssues(fullname: fullname, state: state).host
            components.path = Router.getIssues(fullname: fullname, state: state).path
            components.setQueryItems(with: Router.getIssues(fullname: fullname, state: state).parameters!)
        } else if type == .getPullRequests {
            components.scheme = Router.getPullRequests(fullname: fullname, state: state).scheme
            components.host = Router.getPullRequests(fullname: fullname, state: state).host
            components.path = Router.getPullRequests(fullname: fullname, state: state).path
            components.setQueryItems(with: Router.getPullRequests(fullname: fullname, state: state).parameters!)
        } else if type == .getCommits {
            components.scheme = Router.getCommits(fullname: fullname).scheme
            components.host = Router.getCommits(fullname: fullname).host
            components.path = Router.getCommits(fullname: fullname).path
            components.setQueryItems(with: Router.getCommits(fullname: fullname).parameters!)
        } else if type == .getBranches {
            components.scheme = Router.getBranches(fullname: fullname).scheme
            components.host = Router.getBranches(fullname: fullname).host
            components.path = Router.getBranches(fullname: fullname).path
            components.setQueryItems(with: Router.getBranches(fullname: fullname).parameters!)
        } else if type == .getReleases {
            components.scheme = Router.getReleases(fullname: fullname).scheme
            components.host = Router.getReleases(fullname: fullname).host
            components.path = Router.getReleases(fullname: fullname).path
            components.setQueryItems(with: Router.getReleases(fullname: fullname).parameters!)
        }
        
        components.percentEncodedQuery = components.percentEncodedQuery?.removingPercentEncoding
        return components.url
    }
    
    
    func getResults(type: GetType, state: State = .open, query: String = "", language: String = "", fullname: String = "", username: String = "", completion: @escaping QueryResults) {
        dataTask?.cancel()
        guard let url = createURL(type: type, state: state, query: query, language: language, fullname: fullname, username: username) else {
          return
        }
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        print(request)
        dataTask = defaultSession.dataTask(with: request) { [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }
            if let error = error {
                self?.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                self?.updateSearchResults(type: type, data)
                    DispatchQueue.main.async {
                        completion(self?.elements, self?.errorMessage ?? "")
                    }
                }
        }
        dataTask?.resume()
    }
        
      
    private func updateSearchResults(type: GetType, _ data: Data) {
        elements.removeAll()
        var jsonArray: Array<Any>!
        switch type {
        case .getRepository, .getUser, .repository, .user: /// Json return 1 element
            do {
                if let item = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String: AnyObject] {
                    elements.append(Element(JSON: item)!)
                }
            } catch {
                errorMessage += "JSONSerialization error: \(error.localizedDescription)\n"
                return
            }
        case .getIssues, .getPullRequests, .getCommits, .getBranches, .getReleases: /// Json return array
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
        default: break
        }
        
    }
    
}
