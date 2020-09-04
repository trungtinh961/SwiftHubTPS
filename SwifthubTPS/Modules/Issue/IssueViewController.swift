//
//  IssueViewController.swift
//  SwifthubTPS
//
//  Created by TPS on 9/3/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import UIKit

class IssueViewController: UIViewController {
    
    // MARK: - Properties
    
    var repoItem: Repository?
    private var state: State = .open
    private var isLoading = false
    private var downloadTask: URLSessionDownloadTask?
    private var issueGithubAPI = GitHubAPI<Issue>()
    private var issueItems: [Issue]?
    
    @IBOutlet weak var stateSegmentControl: UISegmentedControl!
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
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.issueCell.rawValue)
        
        ///Config layout
        imgAuthor.layer.masksToBounds = true
        imgAuthor.layer.cornerRadius = imgAuthor.frame.width / 2
        
    }
    
    // MARK: - IBActions
    
    @IBAction func stateSegmentControl(_ sender: Any) {
        switch stateSegmentControl.selectedSegmentIndex {
        case 0: state = .open
        case 1: state = .closed
        default: break
        }
        updateTableView()
    }
    
    @IBAction func btnBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Public Method
    
    func updateTableView(){
        isLoading = true
        if state == .open {
            issueGithubAPI.getResults(type: .getIssues, fullname: repoItem?.fullname ?? "") { [weak self] results, errorMessage in
                if let results = results {
                    self?.issueItems = results
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
        } else if state == .closed {
            issueGithubAPI.getResults(type: .getIssues, state: .closed, fullname: repoItem?.fullname ?? "") { [weak self] results, errorMessage in
                if let results = results {
                    self?.issueItems = results
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
    
    
}

// MARK: - UITableViewDataSource
extension IssueViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return issueItems?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.issueCell.rawValue, for: indexPath) as! IssueCell
        let itemCell = issueItems?[indexPath.row]
        if let smallURL = URL(string: itemCell?.user?.avatarUrl ?? "") {
            downloadTask = cell.imgAuthor.loadImage(url: smallURL)
        }
        cell.lbTitle.text = itemCell?.title
        if state == .open {
            cell.lbDescription.text = "#\(itemCell!.number!) opened \(itemCell!.createdAt!.timeAgo()) by \(itemCell!.user!.login!)"
            cell.imgState.tintColor = UIColor("#00934E")
        } else if state == .closed {
            cell.lbDescription.text = "#\(itemCell!.number!) closed \(itemCell!.createdAt!.timeAgo()) by \(itemCell!.user!.login!)"
            cell.imgState.tintColor = .red
        }
        
        cell.lbCommentCount.text = "\(itemCell?.comments ?? 0)"
        cell.lbCommentCount.subviews.forEach({ $0.removeFromSuperview() })
        let labels = itemCell!.labels!
        var currentX: CGFloat = 16
        for tag in labels {
            let tagLabel = UILabel(frame: CGRect(x: currentX, y: 0, width: 35, height: 12))
            tagLabel.text = tag.name
            tagLabel.font = tagLabel.font.withSize(10)
            tagLabel.backgroundColor = UIColor("#\(tag.color!)")
            tagLabel.sizeToFit()
            cell.lbCommentCount.addSubview(tagLabel)
            currentX += tagLabel.frame.width + 2
        }
        return cell
    }
    
    
}

// MARK: - UITableViewDelegate
extension IssueViewController: UITableViewDelegate {
    
}
