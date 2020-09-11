//
//  RepositoryDetailViewController.swift
//  SwifthubTPS
//
//  Created by TPS on 9/10/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import UIKit

enum detailType {
    case repositories
    case followers
    case following
}

class RepositoryDetailViewController: UIViewController {

    // MARK: - Properties
    
    var detailType: detailType?
    private var downloadTask: URLSessionDownloadTask?
    var gitHubAuthenticationManager = GITHUB()
    var userItem: User?
    private var isLoading = false
    private var noResult = false
    private var repositoryGithubAPI = GitHubAPI<Repository>()
    private var userGithubAPI = GitHubAPI<User>()
    private var repoItems: [Repository]?
    private var userItems: [User]?
    
    @IBOutlet weak var imgAuthor: UIImageView!
    @IBOutlet weak var resultTableView: UITableView!
    @IBOutlet weak var navItem: UINavigationItem!
    
    // MARK: - Life Cycles
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if detailType == .repositories {
            navItem.title = "Repositories"
        } else if detailType == .followers {
            navItem.title = "Followers"
        } else {
            navItem.title = "Following"
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
        if let smallURL = URL(string: userItem?.avatarUrl ?? "") {
            downloadTask = imgAuthor.loadImage(url: smallURL)
        }
    }
    
    
    // MARK: - IBActions
    
    @IBAction func btnBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    // MARK: - Private Methods
    
    private func updateTableView(){
        isLoading = true
        resultTableView.reloadData()
        noResult = false
        
        if detailType == .repositories {
            repositoryGithubAPI.getResults(type: .getUserRepositories, gitHubAuthenticationManager: gitHubAuthenticationManager, username: userItem?.login ?? "") { [weak self] results, errorMessage, statusCode in
                if let results = results {
                    if results.count == 0 {
                        self?.noResult = true
                        self?.isLoading = false
                    } else {
                        self?.repoItems = results
                        self?.isLoading = false
                        if let smallURL = URL(string: self?.userItem?.avatarUrl ?? "") {
                            self?.downloadTask = self?.imgAuthor.loadImage(url: smallURL)
                        }
                    }
                    self?.resultTableView.reloadData()
                }
                if !errorMessage.isEmpty {
                    print("Search error: " + errorMessage)
                }
            }
        } else if detailType == .followers {
            userGithubAPI.getResults(type: .getFollowers, gitHubAuthenticationManager: gitHubAuthenticationManager, username: userItem?.login ?? "") { [weak self] results, errorMessage, statusCode in
                if let results = results {
                    if results.count == 0 {
                        self?.noResult = true
                        self?.isLoading = false
                    } else {
                        self?.userItems = results
                        self?.isLoading = false
                        if let smallURL = URL(string: self?.userItem?.avatarUrl ?? "") {
                            self?.downloadTask = self?.imgAuthor.loadImage(url: smallURL)
                        }
                    }
                    self?.resultTableView.reloadData()
                }
                if !errorMessage.isEmpty {
                    print("Search error: " + errorMessage)
                }
            }
        } else {
            userGithubAPI.getResults(type: .getFollowing, gitHubAuthenticationManager: gitHubAuthenticationManager, username: userItem?.login ?? "") { [weak self] results, errorMessage, statusCode in
                if let results = results {
                    if results.count == 0 {
                        self?.noResult = true
                        self?.isLoading = false
                    } else {
                        self?.userItems = results
                        self?.isLoading = false
                        if let smallURL = URL(string: self?.userItem?.avatarUrl ?? "") {
                            self?.downloadTask = self?.imgAuthor.loadImage(url: smallURL)
                        }
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

// MARK: - UITableViewDataSource
extension RepositoryDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading || noResult {
            return 1
        } else if detailType == .repositories {
            return repoItems?.count ?? 0
        } else {
            return userItems?.count ?? 0
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
        } else if detailType == .repositories {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.repositoryCell.rawValue, for: indexPath) as! RepositoryCell
            let itemCell = repoItems![indexPath.row]
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
            let itemCell = userItems![indexPath.row]
            cell.lbFullname.text = itemCell.login
            if let smallURL = URL(string: itemCell.avatarUrl ?? "") {
                downloadTask = cell.imgAuthor.loadImage(url: smallURL)
            }
            return cell
        }
    }
    
}

// MARK: - UITableViewDelegate
extension RepositoryDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        if detailType == .repositories {
            let repositoryViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.repositoryVC.rawValue) as! RepositoryViewController
            repositoryViewController.repositoryItem = repoItems![indexPath.row]
            repositoryViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
            repositoryViewController.modalPresentationStyle = .automatic
            self.present(repositoryViewController, animated:true, completion:nil)
        } else {
            let userViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.userVC.rawValue) as! UserViewController
            userViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
            userViewController.userItem = userItems![indexPath.row]
            userViewController.isTabbarCall = false
            userViewController.modalPresentationStyle = .automatic
            self.present(userViewController, animated:true, completion:nil)
        }
    }
}
