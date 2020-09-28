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

    // MARK: - IBOutlets
    @IBOutlet weak var imgAuthor: UIImageView!
    @IBOutlet weak var resultTableView: UITableView!
    
    // MARK: - Public properties
    var detailType: detailType?
    var gitHubAuthenticationManager = GITHUB()
    var userItem: User?
    
    // MARK: - Private properties
    private var downloadTask: URLSessionDownloadTask?
    private var isLoading = false
    private var noResult = false
    private var repositoryGithubAPI = GitHubAPI<Repository>()
    private var userGithubAPI = GitHubAPI<User>()
    private var repositoryItems: [Repository]?
    private var userItems: [User]?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTableView()
        makeUI()
    }
    
    private func makeUI() {
        if detailType == .repositories {
            self.navigationItem.title = "Repositories"
        } else if detailType == .followers {
            self.navigationItem.title = "Followers"
        } else {
            self.navigationItem.title = "Following"
        }
        ///Register cell
        RegisterTableViewCell.register(tableView: resultTableView, identifier: CellIdentifiers.repositoryCell.rawValue)
        RegisterTableViewCell.register(tableView: resultTableView, identifier: CellIdentifiers.userCell.rawValue)
        RegisterTableViewCell.register(tableView: resultTableView, identifier: CellIdentifiers.loadingCell.rawValue)
        RegisterTableViewCell.register(tableView: resultTableView, identifier: CellIdentifiers.noResultCell.rawValue)
        ///Config layout
        imgAuthor.layer.masksToBounds = true
        imgAuthor.layer.cornerRadius = imgAuthor.frame.width / 2
        if let smallURL = URL(string: userItem?.avatarUrl ?? "") {
            downloadTask = imgAuthor.loadImage(url: smallURL)
        }
    }
    
    // MARK: - IBActions
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Private Methods
    private func updateTableView(){
        isLoading = true
        resultTableView.reloadData()
        noResult = false
        let type: GetType = (gitHubAuthenticationManager.didAuthorizated
                             && gitHubAuthenticationManager.userAuthorizated == userItem)
                             ? .getRepositoryOfAuthenUser
                             : .getUserRepositories
        if detailType == .repositories {
            repositoryGithubAPI.getResults(type: type,
                                           gitHubAuthenticationManager: gitHubAuthenticationManager,
                                           username: userItem?.login ?? "")
            { [weak self] results, errorMessage, statusCode in
                if let results = results {
                    if results.count == 0 {
                        self?.noResult = true
                        self?.isLoading = false
                    } else {
                        self?.repositoryItems = results
                        self?.isLoading = false
                        if let smallURL = URL(string: self?.userItem?.avatarUrl ?? "") {
                            self?.downloadTask = self?.imgAuthor.loadImage(url: smallURL)
                        }
                    }
                    self?.resultTableView.reloadData()
                }
                if !errorMessage.isEmpty {
                    debugPrint(errorMessage)
                }
            }
        } else if detailType == .followers {
            userGithubAPI.getResults(type: .getFollowers,
                                     gitHubAuthenticationManager: gitHubAuthenticationManager,
                                     username: userItem?.login ?? "")
            { [weak self] results, errorMessage, statusCode in
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
                    debugPrint(errorMessage)
                }
            }
        } else {
            userGithubAPI.getResults(type: .getFollowing,
                                     gitHubAuthenticationManager: gitHubAuthenticationManager,
                                     username: userItem?.login ?? "")
            { [weak self] results, errorMessage, statusCode in
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
                    debugPrint(errorMessage)
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
            return repositoryItems?.count ?? 0
        } else {
            return userItems?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.loadingCell.rawValue, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        } else if noResult {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.noResultCell.rawValue, for: indexPath)
            return cell
        } else if detailType == .repositories {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.repositoryCell.rawValue, for: indexPath) as! RepositoryCell
            let itemCell = repositoryItems![indexPath.row]
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
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.userCell.rawValue, for: indexPath) as! UserCell
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
        if !isLoading, !noResult {
            if detailType == .repositories {
                let repositoryViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.repositoryVC.rawValue) as! RepositoryViewController
                repositoryViewController.repositoryItem = repositoryItems![indexPath.row]
                repositoryViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
                self.navigationController?.pushViewController(repositoryViewController, animated: true)
            } else {
                let userViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.userVC.rawValue) as! UserViewController
                userViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
                userViewController.userItem = userItems![indexPath.row]
                userViewController.isTabbarCall = false
                self.navigationController?.pushViewController(userViewController, animated: true)
            }
        }
    }
}
