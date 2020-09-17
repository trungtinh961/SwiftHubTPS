//
//  ForkViewController.swift
//  SwifthubTPS
//
//  Created by TPS on 9/10/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import UIKit

class ForkViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var imgAuthor: UIImageView!
    @IBOutlet weak var resultTableView: UITableView!
    
    // MARK: - Public properties
    var gitHubAuthenticationManager = GITHUB()
    var repositoryItem: Repository?
    
    // MARK: - Private properties
    private var isLoading = false
    private var noResult = false
    private var downloadTask: URLSessionDownloadTask?
    private var forkGithubAPI = GitHubAPI<Repository>()
    private var forkItems: [Repository]?
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTableView()
        makeUI()
    }
    
    private func makeUI() {
        ///Register cell
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.repositoryCell.rawValue)
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.loadingCell.rawValue)
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.noResultCell.rawValue)
        ///Config layout
        imgAuthor.layer.masksToBounds = true
        imgAuthor.layer.cornerRadius = imgAuthor.frame.width / 2
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
        
        forkGithubAPI.getResults(type: .getForks, gitHubAuthenticationManager: gitHubAuthenticationManager, fullname: repositoryItem?.fullname ?? "") { [weak self] results, errorMessage, statusCode in
            if let results = results {
                if results.count == 0 {
                    self?.noResult = true
                    self?.isLoading = false
                } else {
                    self?.forkItems = results
                    self?.isLoading = false
                    if let smallURL = URL(string: self?.repositoryItem?.owner?.avatarUrl ?? "") {
                        self?.downloadTask = self?.imgAuthor.loadImage(url: smallURL)
                    }
                }
                self?.resultTableView.reloadData()
            }
            if !errorMessage.isEmpty {
                debugPrint("Search error: " + errorMessage)
            }
        }
    }
    
}

//MARK: - UITableViewDataSource
extension ForkViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading || noResult {
            return 1
        } else {
            return forkItems?.count ?? 0
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
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.repositoryCell.rawValue, for: indexPath) as! RepositoryCell
            let itemCell = forkItems![indexPath.row]
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
        }
    }
}

//MARK: - UITableViewDelegate
extension ForkViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let repositoryViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.repositoryVC.rawValue) as! RepositoryViewController
        repositoryViewController.repositoryItem = forkItems![indexPath.row]
        repositoryViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
        self.navigationController?.pushViewController(repositoryViewController, animated: true)        
    }
}
