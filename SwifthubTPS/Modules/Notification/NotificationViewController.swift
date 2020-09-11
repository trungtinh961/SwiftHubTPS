//
//  ActivityViewController.swift
//  SwifthubTPS
//
//  Created by TPS on 9/9/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import UIKit
import Toast_Swift


class NotificationViewController: UIViewController {

    //MARK: - Properties
    
    var gitHubAuthenticationManager = GITHUB()
    private var notificationState = NotificationState.unread
    private var isLoading = false
    private var noResult = false
    private var downloadTask: URLSessionDownloadTask?
    private var notificationGithubAPI = GitHubAPI<Notification>()
    private var notificationItems: [Notification]?
    
    @IBOutlet weak var notificationSegmentControl: UISegmentedControl!
    @IBOutlet weak var resultTableView: UITableView!
    
    // MARK: - Life Cycles
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTableView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ///Register cell
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.notificationCell.rawValue)
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.loadingCell.rawValue)
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.noResultCell.rawValue)
    }
    
    // MARK:- IBActions
    
    @IBAction func notificationSegmentControl(_ sender: Any) {
        switch notificationSegmentControl.selectedSegmentIndex {
        case 0: notificationState = .unread
        case 1: notificationState = .participate
        case 2: notificationState = .all
        default: break
        }
        updateTableView()
    }
    
    @IBAction func btnMakeAllRead(_ sender: Any) {
        notificationGithubAPI.getResults(type: .makeNotificationAllRead, gitHubAuthenticationManager: gitHubAuthenticationManager, notificationState: notificationState) {results, errorMessage, statusCode in
            if let statusCode = statusCode {
                if statusCode == 205 {
                    self.view.makeToast("Make as all read!")
                    print("Make as all read!")
                }                
            }
            if !errorMessage.isEmpty {
                print("Search error: " + errorMessage)
            }
        }
    }
    
    // MARK:- Private Methods
    
    private func updateTableView(){
        isLoading = true
        resultTableView.reloadData()
        noResult = false
        
        notificationGithubAPI.getResults(type: .getNotifications, gitHubAuthenticationManager: gitHubAuthenticationManager, notificationState: notificationState) { [weak self] results, errorMessage, statusCode in
            if let results = results {
                if results.count == 0 {
                    self?.noResult = true
                    self?.isLoading = false
                } else {
                    self?.notificationItems = results
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

// MARK: - UITableViewDataSource
extension NotificationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading || noResult {
            return 1
        } else {
            return notificationItems?.count ?? 0
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
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.notificationCell.rawValue, for: indexPath) as! NotificationCell
            let itemCell = notificationItems![indexPath.row]
            let actionText = itemCell.subject?.title ?? ""
            let repoName = itemCell.repository?.fullname ?? ""
            cell.lbTitle.text = "\(repoName)\n\(actionText)"
            cell.lbDescription.text = itemCell.updatedAt?.timeAgo()
            if let smallURL = URL(string: itemCell.repository?.owner?.avatarUrl ?? "") {
                downloadTask = cell.imgAuthor.loadImage(url: smallURL)
            }
            return cell
        }
    }
    
}

// MARK: - UITableViewDelegate
extension NotificationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let itemCell = notificationItems![indexPath.row]
        let repositoryViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.repositoryVC.rawValue) as! RepositoryViewController
        repositoryViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
        repositoryViewController.repositoryItem = itemCell.repository
        repositoryViewController.modalPresentationStyle = .automatic
        self.present(repositoryViewController, animated:true, completion:nil)
    }
}
