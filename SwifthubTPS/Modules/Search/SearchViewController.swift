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
    @IBOutlet weak var searchBar: UISearchBar!
    
    var trendingSince = TrendingSince.daily
    var trendingType = TrendingType.repository
    var language: String?
    
    var downloadTask: URLSessionDownloadTask?
    var trendingRepositories: [TrendingRepository]?
    var trendingUsers: [TrendingUser]?
    var isLoading = false
    
    func updateTableView(language: String? = "") {
        isLoading = true
        let queue = DispatchQueue.global()
        queue.async {
            if self.trendingType == .repository {
                self.trendingRepositories = TrendingGithubAPI.getDatas(type: self.trendingType, language: language ?? "", since: self.trendingSince) as [TrendingRepository]
            } else if self.trendingType == .user {
                self.trendingUsers = TrendingGithubAPI.getDatas(type: self.trendingType, language: language ?? "", since: self.trendingSince) as [TrendingUser]
            }
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.resultTableView.reloadData()
            }
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateTableView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        /// Register cell
        
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.repositoryTrending)
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.userTrending)
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.loading)
        
        
        
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
        if isLoading {
            return 1
        } else if trendingType == . repository {
                return trendingRepositories?.count ?? 0
        } else {
                return trendingUsers?.count ?? 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loading, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        } else if trendingType == .repository {
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
            if let smallURL = URL(string: indexCell.avatarUrl ?? "") {
                downloadTask = cell.imgAuthor.loadImage(url: smallURL)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.userTrending, for: indexPath) as! UserCell
            let indexCell = trendingUsers![indexPath.row]
            cell.lbFullname.text = "\(indexCell.username ?? "") (\(indexCell.name ?? ""))"
            cell.lbDescription.text = "\(indexCell.username ?? "")/\(indexCell.repo?.name ?? "")"
            
            cell.imgAuthor.image = UIImage(named: "Placeholder")
            if let smallURL = URL(string: indexCell.avatar ?? "") {
                downloadTask = cell.imgAuthor.loadImage(url: smallURL)
            }
            return cell
        }
        
    }    
}

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        print(trendingRepositories?[indexPath.row].fullname ?? "")
        
    }
    
}

// MARK:- Search Bar

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached        
    }
    
}



// MARK:- Navigation

extension SearchViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! LanguageViewController
        controller.delegate = self
        controller.language = language
    }
}

extension SearchViewController: LanguageViewControllerDelegate {
    func languageViewControllerDidCancel(_ controller: LanguageViewController) {
        updateTableView()
        dismiss(animated: true, completion: nil)
    }
    
    func languageViewController(_ controller: LanguageViewController, didFinishEditing item: Language) {
        if let urlParam = item.urlParam {
            language = urlParam.removingPercentEncoding
            updateTableView(language: language)
        }
        dismiss(animated: true, completion: nil)
    }
    
    
}
