//
//  TrendingGithubAPI.swift
//  SwifthubTPS
//
//  Created by TPS on 8/27/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import ObjectMapper
import Foundation

enum TrendingSince: String {
    case daily = ""
    case weekly = "weekly"
    case monthly = "monthly"
}

class TrendingGithubAPI<Element: Mappable> {
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    var errorMessage = ""
    var elements: [Element] = []
    typealias JSONDictionary = [String: Any]
    typealias QueryResult = ([Element]?, String) -> Void
    func createURL(type: GetType, language: String, since: TrendingSince) -> URL? {
        var components = URLComponents()
        if type == .repository {            
            components.scheme = Router.getTrendingRepository(language: language, since: since).scheme
            components.host = Router.getTrendingRepository(language: language, since: since).host
            components.path = Router.getTrendingRepository(language: language, since: since).path
            components.setQueryItems(with: Router.getTrendingRepository(language: language, since: since).parameters!)
        } else if type == .user {
            components.scheme = Router.getTrendingUser(language: language, since: since).scheme
            components.host = Router.getTrendingUser(language: language, since: since).host
            components.path = Router.getTrendingUser(language: language, since: since).path
            components.setQueryItems(with: Router.getTrendingUser(language: language, since: since).parameters!)
        } else {
            components.scheme = Router.languages.scheme
            components.host = Router.languages.host
            components.path = Router.languages.path
        }
        components.percentEncodedQuery = components.percentEncodedQuery?.removingPercentEncoding
        return components.url
    }
    
    func getResults(type: GetType, language: String = "", since: TrendingSince = .daily, completion: @escaping QueryResult) {
        var filename = ""
        if type == .repository {
            filename = "TrendingRepositories"
        } else if type == .user {
            filename = "TrendingUsers"
        } else if type == .language {
            filename = "TrendingLanguages"
        }
        if let data = FileHelper.loadJSON(filename: filename) {
            self.updateSearchResults(data)
        }
        dataTask?.cancel()
        guard let url = createURL(type: type, language: language, since: since) else {
          return
        }
        debugPrint(url)
        dataTask = defaultSession.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else {return}
            defer {
                self.dataTask = nil
            }
            if let error = error {
                self.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
                
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == STATUS_CODE.OK {
                    FileHelper.saveJSON(data, filename: filename)
                    self.updateSearchResults(data)
                }
            DispatchQueue.main.async {
                completion(self.elements, self.errorMessage )
            }
        }
        dataTask?.resume()
    }
    
    private func updateSearchResults(_ data: Data) {
        elements.removeAll()
        var jsonArray: Array<Any>!
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
