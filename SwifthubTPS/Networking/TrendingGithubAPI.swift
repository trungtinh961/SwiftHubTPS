//
//  TrendingGithubAPI.swift
//  SwifthubTPS
//
//  Created by TPS on 8/27/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import Foundation

enum TrendingSince: String {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
}

class TrendingGithubAPI {
    
  static func getDatas(language: String, since: TrendingSince) -> [TrendingRepository] {
        var components = URLComponents()
        components.scheme = Router.getTrendingRepository(language: language, since: since).scheme
        components.host = Router.getTrendingRepository(language: language, since: since).host
        components.path = Router.getTrendingRepository(language: language, since: since).path
        components.setQueryItems(with: Router.getTrendingRepository(language: language, since: since).parameters!)
        print(components.url!)
        var data = Data()
        do {
            data = try Data(contentsOf: components.url!)
        } catch {
            print("Download Error: \(error.localizedDescription)")
            
        }
        
        var jsonArray: Array<Any>!
        do {
            jsonArray = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? Array
        } catch {
          print(error)
        }
        var trendingRepositories = [TrendingRepository]()
        for json in jsonArray {
          if let item = json as? [String: AnyObject] {
            trendingRepositories.append(TrendingRepository(JSON: item)!)
          }
        }
        return trendingRepositories
    }
    
}
