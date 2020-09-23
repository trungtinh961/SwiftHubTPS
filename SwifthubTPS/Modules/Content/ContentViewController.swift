//
//  ContentViewController.swift
//  SwifthubTPS
//
//  Created by TPS on 9/16/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import UIKit

class ContentViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Public properties
    var contentItem: Content?
    var repositoryItem: Repository?
    var gitHubAuthenticationManager = GITHUB()
    
    // MARK: - Private properties
    private var isLoading = false
    private var contentGithubAPI = GitHubAPI<Content>()
    private var contentItems: [Content]?
    
    // MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTableView()
        makeUI()
    }
  
    private func makeUI() {
        if let title = repositoryItem?.fullname {
            self.title = title
        }
        /// Register cell
        RegisterTableViewCell.register(tableView: tableView, identifier: CellIdentifiers.contentCell.rawValue)
        RegisterTableViewCell.register(tableView: tableView, identifier: CellIdentifiers.loadingCell.rawValue)
    }
    
    // MARK: - IBActions
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Private Methods
    private func updateTableView(){
        isLoading = true
        tableView.reloadData()
        
        contentGithubAPI.getResults(type: .getContents,
                                    gitHubAuthenticationManager: gitHubAuthenticationManager,
                                    fullname: repositoryItem?.fullname ?? "",
                                    path: contentItem?.path ?? "")
        { [weak self] results, errorMessage, statusCode in
            if let results = results {
                self?.contentItems = results
                self?.contentItems?.sort(by: { $0.type > $1.type } )
                self?.isLoading = false                
                self?.tableView.reloadData()
            }
            if !errorMessage.isEmpty {
                debugPrint(errorMessage)
            }
        }
    }    
}

// MARK: - UITableViewDataSource
extension ContentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 1
        } else {
            return contentItems?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
          let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.loadingCell.rawValue, for: indexPath)
          let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
          spinner.startAnimating()
          return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.contentCell.rawValue, for: indexPath) as! ContentCell
            let itemCell = contentItems?[indexPath.row]
            cell.lbTitle.text = itemCell?.name
            if itemCell?.type != .dir {
                cell.lbSize.isHidden = false
                cell.lbSize.text = itemCell?.size?.sizeFromKB()
                cell.imgContent.image = UIImage(named: ImageName.icon_cell_file.rawValue)
            } else {
                cell.lbSize.isHidden = true
                cell.imgContent.image = UIImage(named: ImageName.icon_cell_dir.rawValue)
            }
            return cell
        }
    }
}


// MARK: - UITableViewDelegate
extension ContentViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let itemCell = contentItems?[indexPath.row]
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        if itemCell?.type == .dir {            
            let contentViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.contentVC.rawValue) as! ContentViewController
            contentViewController.repositoryItem = repositoryItem
            contentViewController.contentItem = itemCell
            contentViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
            self.navigationController?.pushViewController(contentViewController, animated: true)
        } else if itemCell?.type == .file {
            let fileViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.fileVC.rawValue) as! FileViewController
            fileViewController.repositoryItem = repositoryItem
            fileViewController.contentItem = itemCell
            fileViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
            self.navigationController?.pushViewController(fileViewController, animated: true)
        }
    }
}
