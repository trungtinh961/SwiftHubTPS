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
    
    var userItem: User?
    private var isLoading = false
    private var downloadTask: URLSessionDownloadTask?
    private var eventGithubAPI = GitHubAPI<Event>()
    private var eventItems: [Event]?
    
    @IBOutlet weak var imgAuthor: UIImageView!
    @IBOutlet weak var resultTableView: UITableView!
    
    // MARK: - Life Cycle
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
    
}

// MARK: - UITableViewDataSource

extension StarViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loadingCell.rawValue, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.repositoryCell.rawValue, for: indexPath)
            
            return cell
        }
        
        
    }
}

// MARK: - UITableViewDelegate
extension StarViewController: UITableViewDelegate {
    
}
