//
//  WatchingViewController.swift
//  SwifthubTPS
//
//  Created by TPS on 9/7/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import UIKit


class WatchingViewController: UIViewController {

    // MARK: - Properties
    var gitHubAuthenticationManager = GITHUB()
    var getType: GetType?
    var userItem: User?
    var repoItem: Repository?
    private var isLoading = false
    private var noResult = false
    private var downloadTask: URLSessionDownloadTask?
    private var watchingGithubAPI = GitHubAPI<Repository>()
    private var watchingItems: [Repository]?
    private var watcherGithubAPI = GitHubAPI<User>()
    private var watcherItems: [User]?
    
    @IBOutlet weak var imgAuthor: UIImageView!
    @IBOutlet weak var resultTableView: UITableView!
    @IBOutlet weak var navItem: UINavigationItem!
    
    // MARK: - Life Cycles
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if getType == .getWatching {
            self.navigationItem.title = "Watching"
        } else {
            self.navigationItem.title = "Watchers"
        }
        updateTableView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ///Register cell
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.repositoryCell.rawValue)
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.userCell.rawValue)
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.loadingCell.rawValue)
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.noResultCell.rawValue)
        ///Config layout
        imgAuthor.layer.masksToBounds = true
        imgAuthor.layer.cornerRadius = imgAuthor.frame.width / 2
    }
    
    
    
    // MARK:- IBActions
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    // MARK:- Private Methods

    private func updateTableView(){
        isLoading = true
        resultTableView.reloadData()
        noResult = false
        
        if getType == .getWatching {
            watchingGithubAPI.getResults(type: .getWatching, gitHubAuthenticationManager: gitHubAuthenticationManager, username: userItem?.login ?? "") { [weak self] results, errorMessage, statusCode in
                if let results = results {
                    if results.count == 0 {
                        self?.noResult = true
                        self?.isLoading = false
                    } else {
                        self?.watchingItems = results
                        self?.isLoading = false
                        if let smallURL = URL(string: self?.userItem?.avatarUrl ?? "") {
                            self?.downloadTask = self?.imgAuthor.loadImage(url: smallURL)
                        }
                    }
                    self?.resultTableView.reloadData()
                }
                if !errorMessage.isEmpty {
                    debugPrint("Search error: " + errorMessage)
                }
            }
        } else if getType == .getWatchers {
            watcherGithubAPI.getResults(type: .getWatchers, gitHubAuthenticationManager: gitHubAuthenticationManager, fullname: repoItem?.fullname ?? "") { [weak self] results, errorMessage, statusCode in
                if let results = results {
                    if results.count == 0 {
                        self?.noResult = true
                        self?.isLoading = false
                    } else {
                        self?.watcherItems = results
                        self?.isLoading = false
                        if let smallURL = URL(string: self?.repoItem?.owner?.avatarUrl ?? "") {
                            self?.downloadTask = self?.imgAuthor.loadImage(url: smallURL)
                        }
                    }
                    self?.resultTableView.reloadData()
                }
                if !errorMessage.isEmpty {
                    debugPrint("Search error: " + errorMessage)
                }
            }
        }
    }
    
}


// MARK: - UITableViewDataSource
extension WatchingViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading || noResult {
            return 1
        } else {
            if getType == .getWatching {
                return watchingItems?.count ?? 0
            } else {
                return watcherItems?.count ?? 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loadingCell.rawValue, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        } else if noResult {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.noResultCell.rawValue, for: indexPath)
            return cell
        } else if getType == .getWatching {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.repositoryCell.rawValue, for: indexPath) as! RepositoryCell
            let itemCell = watchingItems![indexPath.row]
            cell.lbFullname.text = itemCell.fullname
            cell.lbDescription.text = itemCell.description
            cell.lbStars.text = itemCell.stargazersCount?.kFormatted()
            cell.lbCurrentPeriodStars.text = itemCell.language
            if let smallURL = URL(string: itemCell.owner?.avatarUrl ?? "") {
                downloadTask = cell.imgAuthor.loadImage(url: smallURL)
            }
            cell.imgCurrentPeriodStars.isHidden = true
            cell.lbLanguage.isHidden = true
            cell.viewLanguageColor.isHidden = true
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.userCell.rawValue, for: indexPath) as! UserCell
            let itemCell = watcherItems![indexPath.row]
            cell.lbFullname.text = itemCell.login
            if let smallURL = URL(string: itemCell.avatarUrl ?? "") {
                downloadTask = cell.imgAuthor.loadImage(url: smallURL)
            }
            return cell
        }
    }
    
}



// MARK: - UITableViewDelegate
extension WatchingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        if getType == .getWatching {
            let repositoryViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.repositoryVC.rawValue) as! RepositoryViewController
            repositoryViewController.repositoryItem = watchingItems![indexPath.row]
            repositoryViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
            repositoryViewController.modalPresentationStyle = .automatic
            self.navigationController?.pushViewController(repositoryViewController, animated: true)
        } else {
            let userViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.userVC.rawValue) as! UserViewController
            userViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
            userViewController.userItem = watcherItems![indexPath.row]
            userViewController.isTabbarCall = false
            userViewController.modalPresentationStyle = .automatic
            self.navigationController?.pushViewController(userViewController, animated: true)
        }
        
    }
}
