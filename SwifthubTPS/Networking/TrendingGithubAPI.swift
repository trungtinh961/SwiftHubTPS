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
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
}

enum TrendingType: Int {
    case repository
    case user
    case language
}

class TrendingGithubAPI {
    
    static func createURL(type: TrendingType, language: String, since: TrendingSince) -> URL {
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
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")        
        return components.url!
    }
    
    static func getDatas<T: Mappable>(type: TrendingType, language: String = "", since: TrendingSince = .daily) -> [T] {
        var trendingArray = [T]()
        let url = self.createURL(type: type, language: language, since: since)
        print(url)
        var data = Data()
        do {
            data = try Data(contentsOf: url)
        } catch {
            print("Download Error: \(error.localizedDescription)")
            return trendingArray
        }
        
        var jsonArray: Array<Any>!
        do {
            jsonArray = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? Array
        } catch {
            print(error)
            return trendingArray
        }
                
        
        for json in jsonArray {
          if let item = json as? [String: AnyObject] {
            trendingArray.append(T(JSON: item)!)
          }
        }
        
        return trendingArray
    }
    
}
