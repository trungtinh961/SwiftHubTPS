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
    private var organizations: [User] = []
    
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
            self.navigationItem.leftBarButtonItem?.tintColor = .clear
            self.navigationItem.leftBarButtonItem?.isEnabled = false
            self.navigationItem.rightBarButtonItem?.tintColor = .systemTeal
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            self.navigationItem.leftBarButtonItem?.tintColor = .systemTeal
            self.navigationItem.leftBarButtonItem?.isEnabled = true
            self.navigationItem.rightBarButtonItem?.tintColor = .clear
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
        getData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        
        ///Register cell
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.detailCell.rawValue)
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.userCell.rawValue)
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
        self.navigationItem.setTitle(title: userItem?.login ?? "", subtitle: userItem?.name ?? "")
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
        if self.navigationController?.viewControllers.count == 1 {
            dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
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
        self.navigationController?.pushViewController(repositoryDetailViewController, animated: true)
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
                self?.navigationItem.setTitle(title: self?.userItem?.login ?? "", subtitle: self?.userItem?.name ?? "")
                self?.userDetails = self?.userItem?.getDetailCell()
                if result.type == .user {
                    self?.getOrganizations()
                }
                self?.resultTableView.reloadData()
                self?.updateStatus()
            }
            if !errorMessage.isEmpty {
                print("Search error: " + errorMessage)
            }
        }
        
    }
    
    private func getOrganizations() {
        userGithubAPI.getResults(type: .getOrganizations, gitHubAuthenticationManager: gitHubAuthenticationManager, username: userItem!.login!) { [weak self] results, errorMessage, statusCode in
            if let results = results {
                self?.organizations = results
                self?.resultTableView.reloadData()
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if organizations.count > 0 {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 45))
        headerView.backgroundColor = UIColor("#F5F5F5")
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 4, width: headerView.frame.width - 10, height: 17)
        headerView.addSubview(label)
        if section == 1 {
            label.text = "Orgnizations"
            label.font = UIFont.systemFont(ofSize: 16.0)
        }
        return headerView

    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 1
        } else if section == 0 {
            return userDetails?.count ?? 0
        } else {
            return organizations.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        if section == 0 {
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
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.userCell.rawValue, for: indexPath) as! UserCell
            let indexCell = organizations[indexPath.row]
            cell.lbFullname.text = indexCell.login
            cell.lbDescription.isHidden = true
            if let smallURL = URL(string: indexCell.avatarUrl ?? "") {
                downloadTask = cell.imgAuthor.loadImage(url: smallURL)
            }
            return cell
        }
    }
    
}

// MARK: - UITableViewDelegate
extension UserViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let section = indexPath.section
        if section == 0 {
            let itemCell = userDetails?[indexPath.row]
            print(userDetails?[indexPath.row].id ?? "")
            switch itemCell!.id {
            case "starred":
                let starsViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.starVC.rawValue) as! StarViewController
                starsViewController.modalPresentationStyle = .automatic
                starsViewController.userItem = userItem
                starsViewController.getType = .getStarred
                starsViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
                self.navigationController?.pushViewController(starsViewController, animated: true)
            case "subscriptions":
                let watchingViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.watchingVC.rawValue) as! WatchingViewController
                watchingViewController.modalPresentationStyle = .automatic
                watchingViewController.getType = .getWatching
                watchingViewController.userItem = userItem
                watchingViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
                self.navigationController?.pushViewController(watchingViewController, animated: true)
            case "events":
                let eventViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.userEventVC.rawValue) as! UserEventViewController
                eventViewController.modalPresentationStyle = .automatic
                eventViewController.userItem = userItem
                eventViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
                self.navigationController?.pushViewController(eventViewController, animated: true)
            case "blog":
                if let url = URL(string: userItem?.blog ?? "") {
                    UIApplication.shared.open(url)
                }

            default:
                break
            }
        } else {
            let userViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.userVC.rawValue) as! UserViewController
            userViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
            userViewController.userItem = organizations[indexPath.row]
            userViewController.isTabbarCall = false
            userViewController.modalPresentationStyle = .automatic
            self.navigationController?.pushViewController(userViewController, animated: true)
        }
    }
    
}
