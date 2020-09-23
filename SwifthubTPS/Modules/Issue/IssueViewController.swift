//
//  IssueViewController.swift
//  SwifthubTPS
//
//  Created by TPS on 9/3/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import UIKit

class IssueViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var stateSegmentControl: UISegmentedControl!
    @IBOutlet weak var imgAuthor: UIImageView!
    @IBOutlet weak var resultTableView: UITableView!
    
    // MARK: - Public properties
    var gitHubAuthenticationManager = GITHUB()
    var repositoryItem: Repository?
    
    // MARK: - Private properties
    private var state: IssueState = .open
    private var isLoading = false
    private var noResult = false
    private var downloadTask: URLSessionDownloadTask?
    private var issueGithubAPI = GitHubAPI<Issue>()
    private var issueItems: [Issue]?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTableView()
        makeUI()
    }
    
    private func makeUI() {
        ///Register cell
        RegisterTableViewCell.register(tableView: resultTableView, identifier: CellIdentifiers.issueCell.rawValue)
        RegisterTableViewCell.register(tableView: resultTableView, identifier: CellIdentifiers.loadingCell.rawValue)
        RegisterTableViewCell.register(tableView: resultTableView, identifier: CellIdentifiers.noResultCell.rawValue)
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
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Private Method
    private func updateTableView(){
        isLoading = true
        resultTableView.reloadData()
        noResult = false
                
        issueGithubAPI.getResults(type: .getIssues,
                                  gitHubAuthenticationManager: gitHubAuthenticationManager,
                                  state: state,
                                  fullname: repositoryItem?.fullname ?? "")
        { [weak self] results, errorMessage, statusCode in
            if let results = results {
                if results.count == 0 {
                    self?.noResult = true
                    self?.isLoading = false
                } else {
                    self?.issueItems = results
                    self?.isLoading = false
                    if let smallURL = URL(string: self?.repositoryItem?.owner?.avatarUrl ?? "") {
                        self?.downloadTask = self?.imgAuthor.loadImage(url: smallURL)
                    }
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
extension IssueViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading || noResult {
            return 1
        } else {
            return issueItems?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.loadingCell.rawValue, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        } else if noResult {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.noResultCell.rawValue, for: indexPath)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.issueCell.rawValue, for: indexPath) as! IssueCell
            let itemCell = issueItems?[indexPath.row]
            if let smallURL = URL(string: itemCell?.user?.avatarUrl ?? "") {
                downloadTask = cell.imgAuthor.loadImage(url: smallURL)
            }
            cell.lbTitle.text = itemCell?.title
            if state == .open {
                cell.lbDescription.text = "#\(itemCell!.number!) opened \(itemCell!.createdAt!.toRelative()) by \(itemCell!.user!.login!)"
                cell.imgState.tintColor = UIColor("#00934E")
            } else if state == .closed {
                cell.lbDescription.text = "#\(itemCell!.number!) closed \(itemCell!.createdAt!.toRelative()) by \(itemCell!.user!.login!)"
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
}

// MARK: - UITableViewDelegate
extension IssueViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let chatViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.chatVC.rawValue) as! ChatViewController
        chatViewController.repositoryItem = repositoryItem
        chatViewController.issueItem = issueItems?[indexPath.row]
        chatViewController.gitHubAuthenticationManager = gitHubAuthenticationManager        
        self.navigationController?.pushViewController(chatViewController, animated: true)
    }
}
