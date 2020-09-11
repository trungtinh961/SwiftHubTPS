//
//  UserViewController.swift
//  SwifthubTPS
//
//  Created by TPS on 9/3/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import UIKit

class UserViewController: UIViewController {

    // MARK: - Properties
    var gitHubAuthenticationManager = GITHUB()
    var userItem: User?
    var isTabbarCall = false
    private var downloadTask: URLSessionDownloadTask?
    private var userGithubAPI = GitHubAPI<User>()
    private var isLoading = false
    private var isFollowed = false
    private var userDetails: [DetailCellProperty]?
    private var totalRepos = 0
    
    @IBOutlet weak var resultTableView: UITableView!
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lbDescription: UILabel!
    @IBOutlet weak var lbRepositories: UILabel!
    @IBOutlet weak var lbFollowers: UILabel!
    @IBOutlet weak var lbFollowing: UILabel!
    @IBOutlet weak var repositoriesView: UIView!
    @IBOutlet weak var followersView: UIView!
    @IBOutlet weak var followingView: UIView!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var btnAddUser: UIButton!
    
    // MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if gitHubAuthenticationManager.didAuthenticated, gitHubAuthenticationManager.userAuthenticated != userItem {
            btnAddUser.isHidden = false
            btnAddUser.isEnabled = true
        } else {
            btnAddUser.isHidden = true
            btnAddUser.isEnabled = false
        }
        
        
        if gitHubAuthenticationManager.didAuthenticated, gitHubAuthenticationManager.userAuthenticated == userItem, isTabbarCall {
            navItem.leftBarButtonItem?.tintColor = .clear
            navItem.leftBarButtonItem?.isEnabled = false
            navItem.rightBarButtonItem?.tintColor = .systemTeal
            navItem.rightBarButtonItem?.isEnabled = true
        } else {
            navItem.leftBarButtonItem?.tintColor = .systemTeal
            navItem.leftBarButtonItem?.isEnabled = true
            navItem.rightBarButtonItem?.tintColor = .clear
            navItem.rightBarButtonItem?.isEnabled = false
        }
        getData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        
        ///Register cell
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.detailCell.rawValue)
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.loadingCell.rawValue)
        
        /// Config layout
        imgAvatar.layer.cornerRadius = imgAvatar.frame.height / 2
        imgAvatar.layer.masksToBounds = true
        btnAddUser.layer.cornerRadius = btnAddUser.frame.height / 2
        btnAddUser.layer.masksToBounds = true
        repositoriesView.layer.cornerRadius = 5
        followersView.layer.cornerRadius = 5
        followingView.layer.cornerRadius = 5
        if let smallURL = URL(string: userItem?.avatarUrl ?? "") {
            downloadTask = imgAvatar.loadImage(url: smallURL)
        }
        navItem.setTitle(title: userItem?.login ?? "", subtitle: userItem?.name ?? "")
    }
    
    // MARK: - IBActions
    
    @IBAction func btnAddUser(_ sender: Any) {
        if isFollowed {
            _ = checkFollowUser(type: .unFollowUser)
            btnAddUser.setImage(UIImage(named: ImageName.icon_button_user_plus.rawValue), for: .normal)
            self.view.makeToast("You unfollowed \(userItem?.login ?? "")")
            print("Did unfollowed \(userItem?.login ?? "")")
        } else {
            _ = checkFollowUser(type: .followUser)
            btnAddUser.setImage(UIImage(named: ImageName.icon_button_user_x.rawValue), for: .normal)
            self.view.makeToast("You followed \(userItem?.login ?? "")")
            print("Did followed \(userItem?.login ?? "")")
        }
        isFollowed = !isFollowed
    }
    
    
    @IBAction func btnClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func btnLogout(_ sender: Any) {
        let mainTabBarController = self.storyboard?.instantiateViewController(withIdentifier: StoryboardIdentifier.tabbar.rawValue) as? MainTabBarController
        mainTabBarController?.gitHubAuthenticationManager.didAuthenticated = false
        mainTabBarController?.gitHubAuthenticationManager.accessToken = ""
        self.view.window?.rootViewController = mainTabBarController
        self.view.window?.makeKeyAndVisible()
    }
    
    
    @IBAction func btnRepositories(_ sender: Any) {
        showDetails(detailType: .repositories)
    }
    
    @IBAction func btnFollowers(_ sender: Any) {
        showDetails(detailType: .followers)
    }
    
    
    @IBAction func btnFollowing(_ sender: Any) {
        showDetails(detailType: .following)
    }
    
    private func showDetails(detailType: detailType) {
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let repositoryDetailViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.repositoryDeatailVC.rawValue) as! RepositoryDetailViewController
        repositoryDetailViewController.modalPresentationStyle = .automatic
        repositoryDetailViewController.detailType = detailType
        repositoryDetailViewController.userItem = userItem
        repositoryDetailViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
        self.present(repositoryDetailViewController, animated:true, completion:nil)
    }
    
    // MARK: - Private Method
    
    private func checkFollowUser(type: GetType) -> Bool {
        var isSuccess = false
        userGithubAPI.getResults(type: type, gitHubAuthenticationManager: gitHubAuthenticationManager, username: userItem!.login!) { results, errorMessage, statusCode in
            if let statusCode = statusCode {
                if statusCode == 204 { isSuccess = true }
            }
            if !errorMessage.isEmpty {
                print("Search error: " + errorMessage)
            }
        }
        return isSuccess
    }
    
    
    private func getData() {
        isLoading = true
        userGithubAPI.getResults(type: .getUser, gitHubAuthenticationManager: gitHubAuthenticationManager, username: userItem!.login!) { [weak self] results, errorMessage, statusCode in
            if let result = results?[0] {
                self?.userItem = result
                self?.totalRepos = (self?.userItem?.repositoriesCount ?? 0) + (self?.userItem?.privateRepoCount ?? 0)
                self?.isLoading = false
                if let smallURL = URL(string: self?.userItem?.avatarUrl ?? "") {
                    self?.downloadTask = self?.imgAvatar.loadImage(url: smallURL)
                }
                self?.lbDescription.text = self?.userItem?.bio
                self?.lbRepositories.text = "\(self?.totalRepos ?? 0)"
                self?.lbFollowers.text = "\(self?.userItem?.followers ?? 0)"
                self?.lbFollowing.text = "\(self?.userItem?.following ?? 0)"
                self?.navItem.setTitle(title: self?.userItem?.login ?? "", subtitle: self?.userItem?.name ?? "")
                self?.userDetails = self?.userItem?.getDetailCell()
                self?.resultTableView.reloadData()
                self?.updateStatus()
            }
            if !errorMessage.isEmpty {
                print("Search error: " + errorMessage)
            }
        }
    }
    
    private func updateStatus() {
        if gitHubAuthenticationManager.didAuthenticated, gitHubAuthenticationManager.userAuthenticated != userItem {
            isFollowed = checkFollowUser(type: .checkFollowedUser)
            if  isFollowed {
                btnAddUser.setImage(UIImage(named: ImageName.icon_button_user_x.rawValue), for: .normal)
            } else {
                btnAddUser.setImage(UIImage(named: ImageName.icon_button_user_plus.rawValue), for: .normal)
            }
        }
    }

}

// MARK: - UITableViewDataSource
extension UserViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 1
        } else {
            return userDetails?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loadingCell.rawValue, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.detailCell.rawValue, for: indexPath) as! DetailCell
            
            let itemCell = userDetails?[indexPath.row]
            cell.lbTitleCell.text = itemCell?.titleCell
            cell.lbDetails.text = itemCell?.detail
            if let img = itemCell?.imgName {
                cell.imgCell.image = UIImage(named: img)
            }
            cell.imgDisclosure.isHidden = (itemCell?.hideDisclosure ?? false)            
            return cell
        }
    }
    
}

// MARK: - UITableViewDelegate
extension UserViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let itemCell = userDetails?[indexPath.row]
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        print(userDetails?[indexPath.row].id ?? "")
        
        switch itemCell!.id {
        case "starred":
            let starsViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.starVC.rawValue) as! StarViewController
            starsViewController.modalPresentationStyle = .automatic
            starsViewController.userItem = userItem
            starsViewController.getType = .getStarred
            starsViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
            self.present(starsViewController, animated:true, completion:nil)
        case "subscriptions":
            let watchingViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.watchingVC.rawValue) as! WatchingViewController
            watchingViewController.modalPresentationStyle = .automatic
            watchingViewController.getType = .getWatching
            watchingViewController.userItem = userItem
            watchingViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
            self.present(watchingViewController, animated:true, completion:nil)
        case "events":
            let eventViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.userEventVC.rawValue) as! UserEventViewController
            eventViewController.modalPresentationStyle = .automatic
            eventViewController.userItem = userItem
            eventViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
            self.present(eventViewController, animated:true, completion:nil)
        case "blog":
            if let url = URL(string: userItem?.blog ?? "") {
                UIApplication.shared.open(url)
            }

        default:
            break
        }
                
    }
    
}
