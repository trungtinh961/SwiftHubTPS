//
//  RepositoryViewController.swift
//  SwifthubTPS
//
//  Created by TPS on 9/1/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import UIKit
import Toast_Swift

class RepositoryViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var resultTableView: UITableView!
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lbDescription: UILabel!
    @IBOutlet weak var lbWatches: UILabel!
    @IBOutlet weak var lbStars: UILabel!
    @IBOutlet weak var lbForks: UILabel!
    @IBOutlet weak var watchesView: UIView!
    @IBOutlet weak var starsView: UIView!
    @IBOutlet weak var forksView: UIView!
    @IBOutlet weak var btnWatches: UIButton!
    @IBOutlet weak var btnStarsCount: UIButton!
    @IBOutlet weak var btnForks: UIButton!
    @IBOutlet weak var btnStar: UIButton!
    
    // MARK: - Public properties
    var gitHubAuthenticationManager = GITHUB()
    var repositoryItem: Repository?
    
    // MARK: - Private properties
    private var downloadTask: URLSessionDownloadTask?
    private var repositoryGithubAPI = GitHubAPI<Repository>()
    private var isLoading = false
    private var isStarred = false
    private var repositoryDetails: [DetailCellProperty]?
    private var branch: String?
    private let storyBoard = UIStoryboard(name: "Main", bundle:nil)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTableView()
        makeUI()
    }
    
    private func makeUI() {
        if gitHubAuthenticationManager.didAuthenticated {
            btnStar.isHidden = false
            btnStar.isEnabled = true
        } else {
            btnStar.isHidden = true
            btnStar.isEnabled = false
        }
        self.title = repositoryItem?.fullname
        
        ///Register cell
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.detailCell.rawValue)
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.languageChartCell.rawValue)
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.loadingCell.rawValue)
        
        /// Config layout
        btnStar.layer.cornerRadius = btnStar.frame.height / 2
        btnStar.layer.masksToBounds = true
        imgAvatar.layer.cornerRadius = imgAvatar.frame.height / 2
        imgAvatar.layer.masksToBounds = true
        watchesView.layer.cornerRadius = 5
        starsView.layer.cornerRadius = 5
        forksView.layer.cornerRadius = 5
        btnWatches.isEnabled = false
        btnStarsCount.isEnabled = false
        btnForks.isEnabled = false
        if let smallURL = URL(string: repositoryItem?.owner?.avatarUrl ?? "") {
            downloadTask = imgAvatar.loadImage(url: smallURL)
        }
    }
    
    // MARK: - IBActions
    @IBAction func btnStar(_ sender: Any) {
        if isStarred {
            isStarred = !isStarred
            checkStarRepository(type: .unStarRepository)
            self.view.makeToast("You unstarred \(repositoryItem?.fullname ?? "")")
            debugPrint("Did unstarred \(repositoryItem?.fullname ?? "")")
        } else {
            isStarred = !isStarred
            checkStarRepository(type: .starRepository)
            self.view.makeToast("You starred \(repositoryItem?.fullname ?? "")")
            debugPrint("Did starred \(repositoryItem?.fullname ?? "")")
        }
        
    }
    
    @IBAction func btnClose(_ sender: Any) {
        if self.navigationController?.viewControllers.count == 1 {
            dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func btnWatches(_ sender: Any) {
        let watchingViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.watchingVC.rawValue) as! WatchingViewController
        watchingViewController.getType = .getWatchers
        watchingViewController.repositoryItem = repositoryItem
        watchingViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
        self.navigationController?.pushViewController(watchingViewController, animated: true)
    }
    
    @IBAction func btnStarsCount(_ sender: Any) {
        let starsViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.starVC.rawValue) as! StarViewController
        starsViewController.repositoryItem = repositoryItem
        starsViewController.getType = .getStargazers
        starsViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
        self.navigationController?.pushViewController(starsViewController, animated: true)
    }
    
    @IBAction func btnForks(_ sender: Any) {
        let forksViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.forkVC.rawValue) as! ForkViewController
        forksViewController.repositoryItem = repositoryItem
        forksViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
        self.navigationController?.pushViewController(forksViewController, animated: true)
    }
    
    // MARK: - Private Methods
    private func updateTableView() {
        isLoading = true
        
        repositoryGithubAPI.getResults(type: .getRepository, gitHubAuthenticationManager: gitHubAuthenticationManager, fullname: repositoryItem!.fullname!) { [weak self] results, errorMessage, statusCode in
            if let result = results?[0] {
                self?.repositoryItem = result
                self?.isLoading = false
                if let smallURL = URL(string: self?.repositoryItem?.owner?.avatarUrl ?? "") {
                    self?.downloadTask = self?.imgAvatar.loadImage(url: smallURL)
                }
                self?.lbDescription.text = self?.repositoryItem?.description
                self?.lbWatches.text = "\(self?.repositoryItem?.subscribersCount ?? 0)"
                self?.lbStars.text = "\(self?.repositoryItem?.stargazersCount ?? 0)"
                self?.lbForks.text = "\(self?.repositoryItem?.forks ?? 0)"
                self?.btnWatches.isEnabled = true
                self?.btnStarsCount.isEnabled = true
                self?.btnForks.isEnabled = true
                self?.branch = self?.repositoryItem?.defaultBranch
                self?.repositoryDetails = self?.repositoryItem?.getDetailCell()
                self?.resultTableView.reloadData()
                self?.checkStarRepository(type: .checkStarredRepository)
            }
            if !errorMessage.isEmpty {
                debugPrint("Search error: " + errorMessage)
            }
        }
    }
    
    
    private func checkStarRepository(type: GetType) {
        repositoryGithubAPI.getResults(type: type, gitHubAuthenticationManager: gitHubAuthenticationManager, fullname: repositoryItem!.fullname!) {results, errorMessage, statusCode in
            if let statusCode = statusCode {
                if statusCode == 204 {
                    if type == .checkStarredRepository {
                        self.isStarred = true
                    }
                    self.updateStatus()
                }
            }
            if !errorMessage.isEmpty {
                debugPrint("Search error: " + errorMessage)
            }
        }
    }
    
    private func updateStatus() {
        if gitHubAuthenticationManager.didAuthenticated {
            if  isStarred {
                btnStar.setImage(UIImage(named: ImageName.icon_button_star.rawValue), for: .normal)
            } else {
                btnStar.setImage(UIImage(named: ImageName.icon_button_unstar.rawValue), for: .normal)
            }
        }
    }
}


// MARK: - UITableViewDataSource
extension RepositoryViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if isLoading {
                return 0
            } else {
                return 1
            }
        } else {
            if isLoading {
                return 1
            } else {
                return repositoryDetails?.count ?? 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        if section == 0 {
            let  cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.languageChartCell.rawValue, for: indexPath) as! LanguageChartCell
            cell.repositoryItem = repositoryItem
            cell.gitHubAuthenticationManager = gitHubAuthenticationManager
            return cell
        } else {
            if isLoading {
                let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loadingCell.rawValue, for: indexPath)
                let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
                spinner.startAnimating()
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.detailCell.rawValue, for: indexPath) as! DetailCell
                let itemCell = repositoryDetails?[indexPath.row]
                cell.lbTitleCell.text = itemCell?.titleCell
                if repositoryDetails?[indexPath.row].id == "branches" {
                    cell.lbDetails.text = branch
                } else {
                    cell.lbDetails.text = itemCell?.detail
                }
                if let img = itemCell?.imgName {
                    cell.imgCell.image = UIImage(named: img)
                }
                cell.imgDisclosure.isHidden = (itemCell?.hideDisclosure ?? false)
                return cell
            }
        }
    }
}


// MARK: - UITableViewDelegate
extension RepositoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let section = indexPath.section
        if section == 1 {
            let itemCell = repositoryDetails?[indexPath.row]
            let storyBoard = UIStoryboard(name: "Main", bundle:nil)
            switch itemCell!.id {
            case "homepage":
                if let url = URL(string: repositoryItem?.homepage ?? "") {
                    UIApplication.shared.open(url)
                }
            case "issues":
                let issuesViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.issueVC.rawValue) as! IssueViewController
                issuesViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
                issuesViewController.repositoryItem = repositoryItem
                self.navigationController?.pushViewController(issuesViewController, animated: true)
            case "pulls":
                let pullsViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.pullVC.rawValue) as! PullRequestViewController
                pullsViewController.repositoryItem = repositoryItem
                pullsViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
                self.navigationController?.pushViewController(pullsViewController, animated: true)
            case "commits":
                let commitsViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.commitVC.rawValue) as! CommitViewController
                commitsViewController.repositoryItem = repositoryItem
                commitsViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
                self.navigationController?.pushViewController(commitsViewController, animated: true)
            case "branches":
                let branchesViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.branchVC.rawValue) as! BranchViewController
                branchesViewController.repositoryItem = repositoryItem
                branchesViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
                branchesViewController.delegate = self
                self.navigationController?.pushViewController(branchesViewController, animated: true)
            case "releases":
                let releaseViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.releaseVC.rawValue) as! ReleaseViewController
                releaseViewController.repositoryItem = repositoryItem
                releaseViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
                self.navigationController?.pushViewController(releaseViewController, animated: true)
            case "contributors":
                let contributorViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.contributorVC.rawValue) as! ContributorViewController
                contributorViewController.repositoryItem = repositoryItem
                contributorViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
                self.navigationController?.pushViewController(contributorViewController, animated: true)
            case "events":
                let eventViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.repoEventVC.rawValue) as! RepositoryEventViewController
                eventViewController.repositoryItem = repositoryItem
                eventViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
                self.navigationController?.pushViewController(eventViewController, animated: true)
            case "contents":
                let contentViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.contentVC.rawValue) as! ContentViewController
                contentViewController.repositoryItem = repositoryItem
                contentViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
                self.navigationController?.pushViewController(contentViewController, animated: true)
            default:
                break
            }
        }
    }
}

// MARK: - Delegate
extension RepositoryViewController: BranchViewControllerDelegate {
    func branchViewController(_ controller: BranchViewController, didFinishEditing branchSelected: String) {
        self.branch = branchSelected
        resultTableView.reloadData()
        self.navigationController?.popViewController(animated: true)
    }    
}
