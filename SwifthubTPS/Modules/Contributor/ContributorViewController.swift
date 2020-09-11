//
//  ContributorViewController.swift
//  SwifthubTPS
//
//  Created by TPS on 9/4/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import UIKit

class ContributorViewController: UIViewController {

    // MARK: - Properties
    var gitHubAuthenticationManager = GITHUB()
    var repoItem: Repository?
    private var isLoading = false
    private var noResult = false
    private var downloadTask: URLSessionDownloadTask?
    private var contributorGithubAPI = GitHubAPI<User>()
    private var contributorItems: [User]?
    
    @IBOutlet weak var imgAuthor: UIImageView!
    @IBOutlet weak var resultTableView: UITableView!
    
    
     // MARK: - Life Cycle
       
    override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
       updateTableView()
    }

    override func viewDidLoad() {
       super.viewDidLoad()

       ///Register cell
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.contributorCell.rawValue)
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.loadingCell.rawValue)
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.noResultCell.rawValue)
       ///Config layout
       imgAuthor.layer.masksToBounds = true
       imgAuthor.layer.cornerRadius = imgAuthor.frame.width / 2
       
    }
    
     // MARK: - IBActions
    
    @IBAction func btnBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private Method
       
    private func updateTableView(){
        isLoading = true
        resultTableView.reloadData()
        noResult = false
        
        contributorGithubAPI.getResults(type: .getContributors, gitHubAuthenticationManager: gitHubAuthenticationManager, fullname: repoItem?.fullname ?? "") { [weak self] results, errorMessage, statusCode in
           if let results = results {
               if results.count == 0 {
                   self?.noResult = true
                   self?.isLoading = false
               } else {
                   self?.contributorItems = results
                   self?.isLoading = false
                   if let smallURL = URL(string: self?.repoItem?.owner?.avatarUrl ?? "") {
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


// MARK: - UITableViewDataSource
extension ContributorViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading || noResult {
            return 1
        } else {
            return contributorItems?.count ?? 0
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
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.contributorCell.rawValue, for: indexPath) as! ContributorCell
            let itemCell = contributorItems?[indexPath.row]
            if let smallURL = URL(string: itemCell?.avatarUrl ?? "") {
                downloadTask = cell.imgAuthor.loadImage(url: smallURL)
            }
            cell.lbName.text = itemCell?.login
            cell.lbDescription.text = "\(itemCell?.contributions ?? 0) commits"
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension ContributorViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let userViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.userVC.rawValue) as! UserViewController
        userViewController.userItem = contributorItems?[indexPath.row]
        userViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
        userViewController.modalPresentationStyle = .automatic
        self.present(userViewController, animated:true, completion:nil)
    }
}
