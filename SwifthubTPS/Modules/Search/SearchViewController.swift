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
    private var searchRepositoryGithubAPI = GitHubAPI<RepositorySearch>()
    private var searchUserGithubAPI = GitHubAPI<UserSearch>()
    private var trendingSince = TrendingSince.daily
    private var getType = GetType.repository
    private var downloadTask: URLSessionDownloadTask?
    private var trendingRepositories: [TrendingRepository]?
    private var trendingUsers: [TrendingUser]?
    private var searchRepositoryInfor: RepositorySearch?
    private var searchRepostories: [Repository]?
    private var searchUserInfor: UserSearch?
    private var searchUsers: [User]?
    private var language: String?
    private var searchTextCurrent = ""
    private var isLoading = false
    private var isSearching = false
    private var noResult = false
    
    @IBOutlet weak var resultTableView: UITableView!
    @IBOutlet weak var typeApiSegmentControl: UISegmentedControl!
    @IBOutlet weak var sinceApiSegmentControl: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var titleConstraints: NSLayoutConstraint!
    
    // MARK: - LifeCycle
    
    override func viewWillAppear(_ animated: Bool) {
        updateTableView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        /// Register cell
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.repositoryTrending.rawValue)
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.userTrending.rawValue)
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.loading.rawValue)
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.noResult.rawValue)
        
        
   }
    
    // MARK: - IBActions
    
    @IBAction func typeApiSegmentControl(_ sender: Any) {
        switch typeApiSegmentControl.selectedSegmentIndex {
        case 0:
            getType = .repository
        case 1:
            getType = .user
        default: print("default")
        }
        updateTableView(language: language, query: searchTextCurrent)
    }
    
    @IBAction func sinceApiSegmentControl(_ sender: Any) {
        switch sinceApiSegmentControl.selectedSegmentIndex {
        case 0: trendingSince = .daily
        case 1: trendingSince = .weekly
        case 2: trendingSince = .monthly
        default: trendingSince = .daily
        }
        updateTableView(language: language)
    }
    
    // MARK: - Public
    
    // MARK: - Private
    
    private func updateTableView(language: String? = "", query: String = "") {
        isLoading = true
        resultTableView.reloadData()
        noResult = false
        
        if getType == .repository {
            if !isSearching {
                trendingRepositoryGithubAPI.getResults(type: .repository, language: language ?? "", since: self.trendingSince) { [weak self] results, errorMessage in
                    if let results = results {
                        self?.trendingRepositories = results
                        self?.isLoading = false
                        if self?.trendingRepositories?.count == 0 {
                            self?.noResult = true
                        }
                        self?.resultTableView.reloadData()
                    }

                    if !errorMessage.isEmpty {
                        print("Search error: " + errorMessage)
                    }
                }
            } else {
                searchRepositoryGithubAPI.getResults(type: .repository, query: query, language: language ?? "") { [weak self] results, errorMessage in
                  
                    if let result = results {
                        if result.totalCount == 0 {
                            self?.noResult = true
                            self?.isLoading = false
                        } else {
                            self?.searchRepositoryInfor = result
                            self?.searchRepostories = self?.searchRepositoryInfor?.items
                            self?.isLoading = false
                        }
                        self?.resultTableView.reloadData()
                    }
                  
                    if !errorMessage.isEmpty {
                        print("Search error: " + errorMessage)
                    }
                }
            }
        } else if getType == .user {
            if !isSearching {
                trendingUserGithubAPI.getResults(type: getType, language: language ?? "", since: self.trendingSince) { [weak self] results, errorMessage in
                    if let results = results {
                        self?.trendingUsers = results
                        self?.isLoading = false
                        if self?.trendingRepositories?.count == 0 || self?.trendingUsers?.count == 0 {
                            self?.noResult = true
                        }
                        self?.resultTableView.reloadData()
                    }

                    if !errorMessage.isEmpty {
                        print("Search error: " + errorMessage)
                    }
                }
            } else {
                searchUserGithubAPI.getResults(type: .user, query: query, language: language ?? "") { [weak self] results, errorMessage in
                  
                    if let result = results {
                        if result.totalCount == 0 {
                            self?.noResult = true
                            self?.isLoading = false
                        } else {
                            self?.searchUserInfor = result
                            self?.searchUsers = self?.searchUserInfor?.items
                            self?.isLoading = false
                        }
                        self?.resultTableView.reloadData()
                    }
                  
                    if !errorMessage.isEmpty {
                        print("Search error: " + errorMessage)
                    }
                }
            }
        }
    }
}

// MARK:- UITableViewDataSource
extension SearchViewController: UITableViewDataSource {
      
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading || noResult {
            return 1
        } else if getType == . repository {
            if isSearching {
                return searchRepostories?.count ?? 0
            } else {
                return trendingRepositories?.count ?? 0
            }
        } else {
            if isSearching {
                return searchUsers?.count ?? 0
            } else {
                return trendingUsers?.count ?? 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loading.rawValue, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        } else if noResult {
            if isSearching {
                if getType == .repository {
                    lbTitle.text = "0 repositories \n\nSearch results for \(language?.removingPercentEncoding ?? "all")"
                } else if getType == .user {
                    lbTitle.text = "0 users \n\nSearch results for \(language?.removingPercentEncoding ?? "all")"
                }
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.noResult.rawValue, for: indexPath)
            return cell
        } else if getType == .repository {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.repositoryTrending.rawValue, for: indexPath) as! RepositoryCell
            
            if isSearching {
                sinceApiSegmentControl.isHidden = true
                titleConstraints.constant = -32
                lbTitle.text = (searchRepositoryInfor?.totalCount.kFormatted())! + " repositories \n\nSearch results for \(language?.removingPercentEncoding ?? "all")"
                let indexCell = searchRepostories![indexPath.row]
                cell.lbFullname.text = indexCell.fullname
                cell.lbDescription.text = indexCell.description
                cell.lbStars.text = indexCell.stargazersCount?.kFormatted()
                cell.imgCurrentPeriodStars.isHidden = true
                cell.viewLanguageColor.isHidden = true
                cell.lbLanguage.isHidden = true
                cell.lbCurrentPeriodStars.text = indexCell.language
                cell.lbCurrentPeriodStars.sizeToFit()
                if let smallURL = URL(string: indexCell.owner?.avatarUrl ?? "") {
                    downloadTask = cell.imgAuthor.loadImage(url: smallURL)
                }
            } else {
                let indexCell = trendingRepositories![indexPath.row]
                cell.lbFullname.text = indexCell.fullname
                cell.lbDescription.text = indexCell.description
                cell.lbStars.text = indexCell.stars!.kFormatted()
                cell.lbCurrentPeriodStars.text = indexCell.currentPeriodStars!.kFormatted() + " " + trendingSince.rawValue
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
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.userTrending.rawValue, for: indexPath) as! UserCell
            if isSearching {
                sinceApiSegmentControl.isHidden = true
                titleConstraints.constant = -32
                lbTitle.text = (searchUserInfor?.totalCount.kFormatted())! + " users \n\nSearch results for \(language?.removingPercentEncoding ?? "all")"
                let indexCell = searchUsers![indexPath.row]
                cell.lbFullname.text = indexCell.login
                cell.lbDescription.isHidden = true
                if let smallURL = URL(string: indexCell.avatarUrl ?? "") {
                    downloadTask = cell.imgAuthor.loadImage(url: smallURL)
                }
            } else {
                cell.lbDescription.isHidden = false
                let indexCell = trendingUsers![indexPath.row]
                cell.lbFullname.text = "\(indexCell.username ?? "") (\(indexCell.name ?? ""))"
                cell.lbDescription.text = "\(indexCell.username ?? "")/\(indexCell.repo?.name ?? "")"
                cell.imgAuthor.image = UIImage(named: "Placeholder")
                if let smallURL = URL(string: indexCell.avatar ?? "") {
                    downloadTask = cell.imgAuthor.loadImage(url: smallURL)
                }
            }
            return cell
        }
    }    
}

// MARK: - UITableViewDelegate

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        if getType == .repository, !isLoading {
            let cell = tableView.cellForRow(at: indexPath) as! RepositoryCell
            
            let repositoryViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.repositoryVC.rawValue) as! RepositoryViewController
            repositoryViewController.repoFullname = cell.lbFullname.text ?? ""
            repositoryViewController.modalPresentationStyle = .automatic
            self.present(repositoryViewController, animated:true, completion:nil)
            
        } else if getType == .user, !isLoading {
            let cell = tableView.cellForRow(at: indexPath) as! UserCell
            print(cell.lbFullname.text ?? "")
            
        }
        
    }    
}

// MARK:- UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let searchText = searchBar.text, !searchText.isEmpty else {
          return
        }
        searchTextCurrent = searchText
        isSearching = true
        updateTableView(language: language, query: searchText)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            searchTextCurrent = ""
            isSearching = false
            sinceApiSegmentControl.isHidden = false
            titleConstraints.constant = 10
            lbTitle.text = "Trending"
            updateTableView(language: language)
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
            controller.language = language?.removingPercentEncoding
    }
}

extension SearchViewController: LanguageViewControllerDelegate {
    func languageViewControllerDidCancel(_ controller: LanguageViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func languageViewController(_ controller: LanguageViewController, didFinishEditing item: Language) {
        if let urlParam = item.urlParam {
            language = urlParam
            updateTableView(language: language, query: searchTextCurrent)
        }
        dismiss(animated: true, completion: nil)
    }
}
