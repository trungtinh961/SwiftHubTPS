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
    typealias QueryResult = ([Element]?, String) -> Void
    
    func createURL(type: GetType, query: String, language: String) -> URL? {
        var components = URLComponents()
        
        if type == .repository {
            components.scheme = Router.searchRepositories(query: query, language: language).scheme
            components.host = Router.searchRepositories(query: query, language: language).host
            components.path = Router.searchRepositories(query: query, language: language).path
            components.setQueryItems(with: Router.searchRepositories(query: query, language: language).parameters!)
        }
        
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        return components.url
    }
    
    
    func getSearchResults(type: GetType, query: String, language: String = "", completion: @escaping QueryResult) {
        dataTask?.cancel()
        guard let url = createURL(type: type, query: query, language: language) else {
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
                    self?.updateSearchResults(data)
                    DispatchQueue.main.async {
                        completion(self?.elements, self?.errorMessage ?? "")
                    }
                }
        }
        dataTask?.resume()
    }
    
    private func updateSearchResults(_ data: Data) {
        
        elements.removeAll()
        var jsonArray: Array<Any>?
        do {
            jsonArray = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? Array
        } catch {
            errorMessage += "JSONSerialization error: \(error.localizedDescription)\n"
            return
        }
        if let jsonArray = jsonArray {
            for json in jsonArray {
                if let item = json as? [String: AnyObject] {
                    elements.append(Element(JSON: item)!)
                }
            }
        }        
    }
    
}
