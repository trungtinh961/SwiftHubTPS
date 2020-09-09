//
//  StarViewController.swift
//  SwifthubTPS
//
//  Created by TPS on 9/4/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import UIKit

class StarViewController: UIViewController {

    // MARK: - Properties
    var gitHubAuthenticationManager = GITHUB()
    var userItem: User?
    private var isLoading = false
    private var downloadTask: URLSessionDownloadTask?
    private var starredGithubAPI = GitHubAPI<Repository>()
    private var starredItems: [Repository]?
    
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
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.repositoryCell.rawValue)
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.loadingCell.rawValue)
        
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
        starredGithubAPI.getResults(type: .getStarred, gitHubAuthenticationManager: gitHubAuthenticationManager, username: userItem?.login ?? "") { [weak self] results, errorMessage in
            if let results = results {
                self?.starredItems = results
                self?.isLoading = false
                if let smallURL = URL(string: self?.userItem?.avatarUrl ?? "") {
                    self?.downloadTask = self?.imgAuthor.loadImage(url: smallURL)
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

extension StarViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 1
        } else {
            return starredItems?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loadingCell.rawValue, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.repositoryCell.rawValue, for: indexPath) as! RepositoryCell
            let itemCell = starredItems![indexPath.row]
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

// MARK: - UITableViewDelegate
extension StarViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let cell = tableView.cellForRow(at: indexPath) as! RepositoryCell
        let repositoryViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.repositoryVC.rawValue) as! RepositoryViewController
        repositoryViewController.repoFullname = cell.lbFullname.text ?? ""
        repositoryViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
        repositoryViewController.modalPresentationStyle = .automatic
        self.present(repositoryViewController, animated:true, completion:nil)
    }
}
