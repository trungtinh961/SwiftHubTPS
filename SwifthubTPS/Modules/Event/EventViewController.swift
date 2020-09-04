//
//  EventViewController.swift
//  SwifthubTPS
//
//  Created by TPS on 9/4/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import UIKit

class EventViewController: UIViewController {

    // MARK: - Properties
    
    var repoItem: Repository?
    private var isLoading = false
    private var downloadTask: URLSessionDownloadTask?
    private var eventGithubAPI = GitHubAPI<Event>()
    private var eventItems: [Event]?
    
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
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.eventCell.rawValue)
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
        eventGithubAPI.getResults(type: .getEvents, fullname: repoItem?.fullname ?? "") { [weak self] results, errorMessage in
            if let results = results {
                self?.eventItems = results
                self?.isLoading = false
                if let smallURL = URL(string: self?.repoItem?.owner?.avatarUrl ?? "") {
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
extension EventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 1
        } else {
            return eventItems?.count ?? 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loadingCell.rawValue, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.eventCell.rawValue, for: indexPath) as! EventCell
            let itemCell = eventItems?[indexPath.row]
            if let smallURL = URL(string: itemCell?.actor?.avatarUrl ?? "") {
                downloadTask = cell.imgAuthor.loadImage(url: smallURL)
            }
            cell.lbTitle.text = "\(itemCell?.actor?.login ?? "") starred \(itemCell?.repository?.name ?? "")"
            cell.lbTime.text = itemCell?.createdAt?.timeAgo()
            return cell
        }

       
    }
    
    
}

// MARK: - UITableViewDelegate
extension EventViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}
