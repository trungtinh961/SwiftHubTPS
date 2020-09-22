//
//  CommitViewController.swift
//  SwifthubTPS
//
//  Created by TPS on 9/4/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import UIKit

class CommitViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var resultTableView: UITableView!
    
    // MARK: - Public properties
    var gitHubAuthenticationManager = GITHUB()
    var repositoryItem: Repository?
    
    // MARK: - Private properties
    private var isLoading = false
    private var noResult = false
    private var downloadTask: URLSessionDownloadTask?
    private var commitGithubAPI = GitHubAPI<Commit>()
    private var commitItems: [Commit]?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTableView()
        makeUI()
    }
    
    private func makeUI() {
        self.title = repositoryItem?.fullname!
        ///Register cell
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.commitCell.rawValue)
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.loadingCell.rawValue)
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.noResultCell.rawValue)
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
        
        commitGithubAPI.getResults(type: .getCommits, gitHubAuthenticationManager: gitHubAuthenticationManager, fullname: repositoryItem?.fullname ?? "") { [weak self] results, errorMessage, statusCode in
            if let results = results {
                if results.count == 0 {
                    self?.noResult = true
                    self?.isLoading = false
                } else {
                    self?.commitItems = results
                    self?.isLoading = false
                }
                self?.resultTableView.reloadData()
            }
            if !errorMessage.isEmpty {
                debugPrint(errorMessage)
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension CommitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading || noResult {
            return 1
        } else {
            return commitItems?.count ?? 0
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
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.commitCell.rawValue, for: indexPath) as! CommitCell
            let itemCell = commitItems?[indexPath.row]
            if let smallURL = URL(string: itemCell?.author?.avatarUrl ?? "") {
                downloadTask = cell.imgAuthor.loadImage(url: smallURL)
            }
            cell.lbMessage.text = itemCell?.commit?.message
            cell.lbDescription.text = itemCell?.commit?.author?.date?.toRelative()
            let index = itemCell?.sha?.index((itemCell?.sha!.startIndex)!, offsetBy: 7)
            let subSHA = itemCell?.sha?.prefix(upTo: index!)
            cell.lbTag.text = String(subSHA!)
            return cell
        }
    }    
}

// MARK: - UITableViewDelegate
extension CommitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let url = URL(string: commitItems![indexPath.row].htmlUrl ?? "") {
            UIApplication.shared.open(url)
        }
    }
}
