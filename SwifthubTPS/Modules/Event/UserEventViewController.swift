//
//  UserEventViewController.swift
//  SwifthubTPS
//
//  Created by TPS on 9/7/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import UIKit


class UserEventViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var imgAuthor: UIImageView!
    @IBOutlet weak var resultTableView: UITableView!
    @IBOutlet var btnBack: UIBarButtonItem!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    // MARK: - Public properties
    var gitHubAuthenticationManager = GITHUB()
    var userItem: User?
    var didAuthenticated: Bool = false
    var isTabbarCall = false
    
    // MARK: - Private properties
    private var eventType = EventType.received
    private var isLoading = false
    private var noResult = false
    private var downloadTask: URLSessionDownloadTask?
    private var eventGithubAPI = GitHubAPI<Event>()
    private var eventItems: [Event]?
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTableView(eventType: eventType)        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()
    }
    
    private func makeUI() {
        if gitHubAuthenticationManager.didAuthorizated, gitHubAuthenticationManager.userAuthorizated == userItem, isTabbarCall {
            self.navigationItem.leftBarButtonItem?.tintColor = .clear
        } else {
            self.navigationItem.leftBarButtonItem?.tintColor = .systemTeal
        }
        ///Register cell
        RegisterTableViewCell.register(tableView: resultTableView, identifier: CellIdentifiers.eventCell.rawValue)
        RegisterTableViewCell.register(tableView: resultTableView, identifier: CellIdentifiers.loadingCell.rawValue)
        RegisterTableViewCell.register(tableView: resultTableView, identifier: CellIdentifiers.noResultCell.rawValue)
        ///Config layout
        imgAuthor.layer.masksToBounds = true
        imgAuthor.layer.cornerRadius = imgAuthor.frame.width / 2
    }
    
    // MARK: - IBActions
    @IBAction func btnBack(_ sender: Any) {
        if self.navigationController?.viewControllers.count == 1 {
            dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func segmentControl(_ sender: Any) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            eventType = .received
        case 1:
            eventType = .performed
        default: break
        }
        updateTableView(eventType: eventType)
    }
    
    // MARK: - Private Method
    private func updateTableView(eventType: EventType){
        isLoading = true
        resultTableView.reloadData()
        noResult = false

        eventGithubAPI.getResults(type: .getUserEvents,
                                  eventType: eventType,
                                  gitHubAuthenticationManager: gitHubAuthenticationManager,
                                  username: userItem?.login ?? "")
        { [weak self] results, errorMessage, statusCode in
                if let results = results {
                    if results.count == 0 {
                        self?.noResult = true
                        self?.isLoading = false
                    } else {
                        self?.eventItems = results
                        self?.isLoading = false
                        if let smallURL = URL(string: self?.userItem?.avatarUrl ?? "") {
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
extension UserEventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading || noResult {
            return 1
        } else {
            return eventItems?.count ?? 0
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
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.eventCell.rawValue, for: indexPath) as! EventCell
            let itemCell = eventItems?[indexPath.row]
            if let smallURL = URL(string: itemCell?.actor?.avatarUrl ?? "") {
                downloadTask = cell.imgAuthor.loadImage(url: smallURL)
            }
            cell.lbTime.text = itemCell?.createdAt?.toRelative()
            cell.lbTitle.text = itemCell?.title
            if let img = itemCell?.badgeImage {
                cell.imgState.image = UIImage(named: img)
            }
            cell.lbDetail.text = itemCell?.body
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension UserEventViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if !isLoading, !noResult {
            let storyBoard = UIStoryboard(name: "Main", bundle:nil)
            let repositoryViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.repositoryVC.rawValue) as! RepositoryViewController
            repositoryViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
            repositoryViewController.repositoryItem = eventItems?[indexPath.row].repository
            repositoryViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
            if gitHubAuthenticationManager.didAuthorizated, gitHubAuthenticationManager.userAuthorizated == userItem {
                let navController = UINavigationController(rootViewController: repositoryViewController)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated:true, completion: nil)
            } else {
                self.navigationController?.pushViewController(repositoryViewController, animated: true)
            }
        }
    }
}
