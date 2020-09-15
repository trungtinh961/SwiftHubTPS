//
//  StarViewController.swift
//  SwifthubTPS
//
//  Created by TPS on 9/4/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import UIKit

class StarViewController: UIViewController {

    // MARK: - Properties
    var gitHubAuthenticationManager = GITHUB()
    var getType: GetType?
    var userItem: User?
    var repoItem: Repository?
    private var isLoading = false
    private var noResult = false
    private var downloadTask: URLSessionDownloadTask?
    private var starredGithubAPI = GitHubAPI<Repository>()
    private var starredItems: [Repository]?
    private var stargazersGithubAPI = GitHubAPI<User>()
    private var stargazersItems: [User]?
    
    @IBOutlet weak var imgAuthor: UIImageView!
    @IBOutlet weak var resultTableView: UITableView!
    @IBOutlet weak var navItem: UINavigationItem!
    
    // MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if getType == .getStarred {
            self.navigationItem.title = "Starred"
        } else {
            self.navigationItem.title = "Stargazers"
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
    

    // MARK: - IBActions
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - Private Method
    
    private func updateTableView(){
        isLoading = true
        resultTableView.reloadData()
        noResult = false
        
        if getType == .getStarred {
            starredGithubAPI.getResults(type: .getStarred, gitHubAuthenticationManager: gitHubAuthenticationManager, username: userItem?.login ?? "") { [weak self] results, errorMessage, statusCode in
                if let results = results {
                    if results.count == 0 {
                        self?.noResult = true
                        self?.isLoading = false
                    } else {
                        self?.starredItems = results
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
        } else {
            stargazersGithubAPI.getResults(type: .getStargazers, gitHubAuthenticationManager: gitHubAuthenticationManager, fullname: repoItem?.fullname ?? "") { [weak self] results, errorMessage, statusCode in
                if let results = results {
                    if results.count == 0 {
                        self?.noResult = true
                        self?.isLoading = false
                    } else {
                        self?.stargazersItems = results
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

extension StarViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading || noResult {
            return 1
        } else {
            if getType == .getStarred {
                return starredItems?.count ?? 0
            } else {
                return stargazersItems?.count ?? 0
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
        } else if getType == .getStarred {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.repositoryCell.rawValue, for: indexPath) as! RepositoryCell
            let itemCell = starredItems![indexPath.row]
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
        }  else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.userCell.rawValue, for: indexPath) as! UserCell
            let itemCell = stargazersItems![indexPath.row]
            cell.lbFullname.text = itemCell.login
            if let smallURL = URL(string: itemCell.avatarUrl ?? "") {
                downloadTask = cell.imgAuthor.loadImage(url: smallURL)
            }
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension StarViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        if getType == .getStarred {            
            let repositoryViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.repositoryVC.rawValue) as! RepositoryViewController
            repositoryViewController.repositoryItem = starredItems![indexPath.row]
            repositoryViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
            repositoryViewController.modalPresentationStyle = .automatic
            self.navigationController?.pushViewController(repositoryViewController, animated: true)
        } else {
            let userViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.userVC.rawValue) as! UserViewController
            userViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
            userViewController.userItem = stargazersItems![indexPath.row]
            userViewController.isTabbarCall = false
            userViewController.modalPresentationStyle = .automatic
            self.navigationController?.pushViewController(userViewController, animated: true)
        }
        
    }
}
