//
//  ReleaseViewController.swift
//  SwifthubTPS
//
//  Created by TPS on 9/4/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import UIKit

class ReleaseViewController: UIViewController {

    // MARK: - Properties
    var gitHubAuthenticationManager = GITHUB()
    var repoItem: Repository?
    private var isLoading = false
    private var noResult = false
    private var downloadTask: URLSessionDownloadTask?
    private var releaseGithubAPI = GitHubAPI<Release>()
    private var releaseItems: [Release]?
    
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var resultTableView: UITableView!
    
    
    // MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navItem.title = repoItem?.fullname!
        updateTableView()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ///Register cell
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.releaseCell.rawValue)
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.loadingCell.rawValue)
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.noResultCell.rawValue)
    }
    
    @IBAction func btnBack(_ sender: Any) {
            dismiss(animated: true, completion: nil)
    }
        
    // MARK: - Private Method
   
    private func updateTableView(){
        isLoading = true
        resultTableView.reloadData()
        noResult = false
        
        releaseGithubAPI.getResults(type: .getReleases, gitHubAuthenticationManager: gitHubAuthenticationManager, fullname: repoItem?.fullname ?? "") { [weak self] results, errorMessage in
            if let results = results {
                if results.count == 0 {
                    self?.noResult = true
                    self?.isLoading = false
                } else {
                    self?.releaseItems = results
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

extension ReleaseViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading || noResult {
            return 1
        } else {
            return releaseItems?.count ?? 0
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
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.releaseCell.rawValue, for: indexPath) as! ReleaseCell
            let itemCell = releaseItems![indexPath.row]
            if let smallURL = URL(string: itemCell.author?.avatarUrl ?? "") {
                downloadTask = cell.imgAuthor.loadImage(url: smallURL)
            }
            cell.lbName.text = "\(itemCell.tagName ?? "") - \(itemCell.name  ?? "")"
            cell.lbTime.text = itemCell.createdAt?.timeAgo()
            cell.lbBody.text = itemCell.body
            return cell
        }
    }
    
    
}

// MARK: - UITableViewDelegate

extension ReleaseViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let url = URL(string: releaseItems![indexPath.row].htmlUrl ?? "") {
            UIApplication.shared.open(url)
        }
    }
}
