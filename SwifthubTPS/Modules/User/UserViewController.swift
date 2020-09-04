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
    
    private var downloadTask: URLSessionDownloadTask?
    var username: String?
    private var userGithubAPI = GitHubAPI<User>()
    private var userItem: User?
    private var isLoading = false
    private var userDetails: [DetailCellProperty]?
    
    
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
    
    // MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ///Register cell
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.detailCell.rawValue)
        
        
        /// Config layout
        imgAvatar.layer.cornerRadius = imgAvatar.frame.height / 2
        imgAvatar.layer.masksToBounds = true
        repositoriesView.layer.cornerRadius = 5
        followersView.layer.cornerRadius = 5
        followingView.layer.cornerRadius = 5
        
    }
    
    // MARK: - IBActions
    
    @IBAction func btnClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Private Method
    
    private func getData() {
        isLoading = true
        userGithubAPI.getResults(type: .getUser, username: username!) { [weak self] results, errorMessage in
            if let result = results?[0] {
                self?.userItem = result
                self?.isLoading = false
                if let smallURL = URL(string: self?.userItem?.avatarUrl ?? "") {
                    self?.downloadTask = self?.imgAvatar.loadImage(url: smallURL)
                }
                self?.lbDescription.text = self?.userItem?.bio
                self?.lbRepositories.text = "\(self?.userItem?.repositoriesCount ?? 0)"
                self?.lbFollowers.text = "\(self?.userItem?.followers ?? 0)"
                self?.lbFollowing.text = "\(self?.userItem?.following ?? 0)"
                self?.navItem.setTitle(title: self?.userItem?.login ?? self!.username!, subtitle: self?.userItem?.name ?? "")
                self?.userDetails = self?.userItem?.getDetailCell()
                self?.resultTableView.reloadData()
            }
            if !errorMessage.isEmpty {
                print("Search error: " + errorMessage)
            }
        }
    }

}

// MARK: - UITableViewDataSource
extension UserViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userDetails?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

// MARK: - UITableViewDelegate
extension UserViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
                
    }
    
}
