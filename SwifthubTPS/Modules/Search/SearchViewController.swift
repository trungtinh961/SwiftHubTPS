//
//  FirstViewController.swift
//  SwifthubTPS
//
//  Created by TPS on 8/24/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import UIKit
//import HMSegmentedControl
import UIColor_Hex_Swift

class SearchViewController: UIViewController {

    
    @IBOutlet weak var resultTableView: UITableView!
    @IBOutlet weak var typeApiSegmentControl: UISegmentedControl!
    @IBOutlet weak var sinceApiSegmentControl: UISegmentedControl!
    
    var trendingSince = TrendingSince.daily
    var trendingType = TrendingType.repository
    
    var downloadTask: URLSessionDownloadTask?
    var trendingRepositories: [TrendingRepository]?
    var trendingUsers: [TrendingUser]?
    
    func updateTableView() {
        if trendingType == .repository {
            trendingRepositories = TrendingGithubAPI.getDatas(type: trendingType, language: "c++", since: trendingSince) as [TrendingRepository]
        } else {
            trendingUsers = TrendingGithubAPI.getDatas(type: trendingType, language: "c++", since: trendingSince) as [TrendingUser]
//            for item in trendingUsers! {
//                print("Got results: \(item.username ?? "")")
//            }
        }
        
        resultTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Register cell
        
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.repositoryTrending)
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.userTrending)
        
        /// Get data
        
        trendingRepositories = TrendingGithubAPI.getDatas(type: trendingType, language: "", since: trendingSince)
//        for item in trendingRepositories! {
//            print("Got results: \(item.fullname ?? "")")
//
//        }
    }
    
    // MARK:- Action
    
    @IBAction func btnLanguage(_ sender: Any) {
    }
    
    @IBAction func typeApiSegmentControl(_ sender: Any) {
        switch typeApiSegmentControl.selectedSegmentIndex {
        case 0:
            trendingType = .repository
        case 1:
            trendingType = .user
        default: print("default")
        }
        updateTableView()
    }
    
    @IBAction func sinceApiSegmentControl(_ sender: Any) {
        switch sinceApiSegmentControl.selectedSegmentIndex {
        case 0: trendingSince = .daily
        case 1: trendingSince = .weekly
        case 2: trendingSince = .monthly
        default: trendingSince = .daily
        }
        updateTableView()
    }
}

// MARK:- UI Table View

extension SearchViewController: UITableViewDataSource {
      
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if trendingType == . repository {
            return trendingRepositories!.count
        } else {
            return trendingUsers!.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if trendingType == .repository {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.repositoryTrending, for: indexPath) as! RepositoryCell
            let indexCell = trendingRepositories![indexPath.row]
            cell.lbFullname.text = indexCell.fullname
            cell.lbDescription.text = indexCell.description
            cell.lbStars.text = indexCell.stars!.kFormatted()
            cell.lbCurrentPeriodStars.text = indexCell.currentPeriodStars!.kFormatted()
            cell.lbLanguage.isHidden = false
            cell.viewLanguageColor.isHidden = false
            cell.lbLanguage.text = indexCell.language
            if let color = indexCell.languageColor {
                cell.viewLanguageColor.backgroundColor = UIColor(color)
            } else {
                cell.viewLanguageColor.isHidden = true
                cell.lbLanguage.isHidden = true
            }
            cell.imgAuthor.image = UIImage(named: "Placeholder")
            if let smallURL = URL(string: indexCell.avatarUrl!) {
                downloadTask = cell.imgAuthor.loadImage(url: smallURL)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.userTrending, for: indexPath) as! UserCell
            let indexCell = trendingUsers![indexPath.row]
            cell.lbFullname.text = "\(indexCell.username ?? "") (\(indexCell.name ?? ""))"
            cell.lbDescription.text = "\(indexCell.username ?? "")/\(indexCell.repo?.name ?? "")"
            
            cell.imgAuthor.image = UIImage(named: "Placeholder")
            if let smallURL = URL(string: indexCell.avatar!) {
                downloadTask = cell.imgAuthor.loadImage(url: smallURL)
            }
            return cell
        }
        
    }
    
}

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        print(trendingRepositories?[indexPath.row].fullname as Any)
        
    }
    
}

// MARK:- Helper Methods


//extension SearchViewController {
//
//    func hostURL(language: String, since: String) -> URL {
//        var components = URLComponents()
//        components.scheme = Router.getTrendingRepository(language: "", since: "").scheme
//        components.host = Router.getTrendingRepository(language: "", since: "").host
//        components.path = Router.getTrendingRepository(language: "", since: "").path
//        components.setQueryItems(with: Router.getTrendingRepository(language: "", since: "").parameters!)
//        return components.url!
//    }
//
//    func performStoreRequest(with url: URL) -> Data? {
//
//        do {
//            return try Data(contentsOf: url)
//        } catch {
//            print("Download Error: \(error.localizedDescription)")
//            return nil
//        }
//    }
//
//
//    func parse(data: Data) -> [TrendingRepository] {
//        var jsonArray: Array<Any>!
//        do {
//            jsonArray = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? Array
//        } catch {
//          print(error)
//        }
//        var trendingRepositories = [TrendingRepository]()
//        for json in jsonArray {
//          if let item = json as? [String: AnyObject] {
//            trendingRepositories.append(TrendingRepository(JSON: item)!)
//          }
//        }
//        return trendingRepositories
//    }
//
//    func showNetworkError() {
//        let alert = UIAlertController(title: "Whoops...", message: "There was an error accessing the iTunes Store." + " Please try again.", preferredStyle: .alert)
//        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
//        present(alert, animated: true, completion: nil)
//        alert.addAction(action)
//    }
//
//}
//
//

