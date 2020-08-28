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
        if self.trendingType == .repository {
            self.trendingRepositories = TrendingGithubAPI.getDatas(type: self.trendingType, language: "", since: self.trendingSince) as [TrendingRepository]
        } else if self.trendingType == .user {
            self.trendingUsers = TrendingGithubAPI.getDatas(type: self.trendingType, language: "", since: self.trendingSince) as [TrendingUser]
        }
        self.resultTableView.reloadData()
//        let queue = DispatchQueue.global()
//        queue.async {
//            if self.trendingType == .repository {
//                self.trendingRepositories = TrendingGithubAPI.getDatas(type: self.trendingType, language: "", since: self.trendingSince) as [TrendingRepository]
//            } else {
//                self.trendingUsers = TrendingGithubAPI.getDatas(type: self.trendingType, language: "", since: self.trendingSince) as [TrendingUser]
//            }
//        }
//        DispatchQueue.main.async {
//            self.resultTableView.reloadData()
//        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Register cell
        
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.repositoryTrending)
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.userTrending)
        
        /// Get data
        
        updateTableView()
        
    }
    
    // MARK:- Action
    
    @IBAction func btnLanguage(_ sender: Any) {
//        let languageViewController = (self.storyboard?.instantiateViewController(identifier: "LanguageViewController"))! as LanguageViewController
//        self.navigationController?.pushViewController(languageViewController, animated: false)
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
            return trendingRepositories?.count ?? 0
        } else {
            return trendingUsers?.count ?? 0
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


