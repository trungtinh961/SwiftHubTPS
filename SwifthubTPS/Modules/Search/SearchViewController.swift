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
    // MARK: - Properties
    private var trendingRepositoryGithubAPI = TrendingGithubAPI<TrendingRepository>()
    private var trendingUserGithubAPI = TrendingGithubAPI<TrendingUser>()
    private var trendingSince = TrendingSince.daily
    private var trendingType = GetType.repository
    private var language: String?
    private var downloadTask: URLSessionDownloadTask?
    private var trendingRepositories: [TrendingRepository]?
    private var trendingUsers: [TrendingUser]?
    private var isLoading = false
    private var noResult = false
    private var searchResults: [TrendingRepository] = []
    
    @IBOutlet weak var resultTableView: UITableView!
    @IBOutlet weak var typeApiSegmentControl: UISegmentedControl!
    @IBOutlet weak var sinceApiSegmentControl: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - LifeCycle
    
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
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.noResult)
        
        trendingRepositoryGithubAPI.getSearchResults(type: .repository) { [weak self] results, errorMessage in
          if let results = results {
            self?.searchResults = results
            for element in results {
                print(element.fullname!)
            }
          }
          
          if !errorMessage.isEmpty {
            print("Search error: " + errorMessage)
          }
        }
   }
    
    // MARK: - IBActions
    
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
    
    // MARK: - Public
    
    // MARK: - Private
    
    private func updateTableView(language: String? = "") {
        isLoading = true
        noResult = false
        let queue = DispatchQueue.global()
        queue.async {
            if self.trendingType == .repository {
                self.trendingRepositories = self.trendingRepositoryGithubAPI.getDatas(type: self.trendingType, language: language ?? "", since: self.trendingSince) as [TrendingRepository]
            } else if self.trendingType == .user {
                self.trendingUsers = self.trendingUserGithubAPI.getDatas(type: self.trendingType, language: language ?? "", since: self.trendingSince) as [TrendingUser]
            }
            
            DispatchQueue.main.async {
                self.isLoading = false
                if self.trendingRepositories?.count == 0 || self.trendingUsers?.count == 0 {
                    self.noResult = true
                }
                self.resultTableView.reloadData()
            }
        }
    }
}

// MARK:- UITableViewDataSource
extension SearchViewController: UITableViewDataSource {
      
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading || noResult {
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
        } else if noResult {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.noResult, for: indexPath)
            
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

// MARK: - UITableViewDelegate

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print(trendingRepositories?[indexPath.row].fullname ?? "")
    }
    
}

// MARK:- UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let searchText = searchBar.text, !searchText.isEmpty else {
          return
        }
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
