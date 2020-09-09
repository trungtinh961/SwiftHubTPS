//
//  ActivityViewController.swift
//  SwifthubTPS
//
//  Created by TPS on 9/9/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import UIKit



class NotificationViewController: UIViewController {

    //MARK: - Properties
    
    var gitHubAuthenticationManager = GITHUB()
    private var notificationState = NotificationState.unread
    private var isLoading = false
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
        
    }
    
    // MARK:- IBActions
    
    @IBAction func notificationSegmentControl(_ sender: Any) {
        switch notificationSegmentControl.selectedSegmentIndex {
        case 0: notificationState = .unread
        case 1: notificationState = .participate
        case 2: notificationState = .all
        default: break
        }
        resultTableView.reloadData()
    }
    
    
    // MARK:- Private Methods
    
    private func updateTableView(){
        isLoading = true
        resultTableView.reloadData()
        notificationGithubAPI.getResults(type: .getNotifications, gitHubAuthenticationManager: gitHubAuthenticationManager, notificationState: notificationState) { [weak self] results, errorMessage in
            if let results = results {
                self?.notificationItems = results
                self?.isLoading = false
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
        if isLoading {
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
    }
}
