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

    // MARK: - Properties
    
    private var downloadTask: URLSessionDownloadTask?
    var gitHubAuthenticationManager = GITHUB()
    private var repositoryGithubAPI = GitHubAPI<Repository>()
    var repositoryItem: Repository?
    private var isLoading = false
    private var isStarred = false
    private var repositoryDetails: [DetailCellProperty]?
    private var branch: String?
    private let storyBoard = UIStoryboard(name: "Main", bundle:nil)
    
    @IBOutlet weak var resultTableView: UITableView!
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lbDescription: UILabel!
    @IBOutlet weak var lbWatches: UILabel!
    @IBOutlet weak var lbStars: UILabel!
    @IBOutlet weak var lbForks: UILabel!
    @IBOutlet weak var watchesView: UIView!
    @IBOutlet weak var starsView: UIView!
    @IBOutlet weak var forksView: UIView!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var btnWatches: UIButton!
    @IBOutlet weak var btnStarsCount: UIButton!
    @IBOutlet weak var btnForks: UIButton!
    @IBOutlet weak var btnStar: UIButton!
    
    
    // MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if gitHubAuthenticationManager.didAuthenticated {
            btnStar.isHidden = false
            btnStar.isEnabled = true
        } else {
            btnStar.isHidden = true
            btnStar.isEnabled = false            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navItem.title = repositoryItem?.fullname
        getData()
        ///Register cell
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.detailCell.rawValue)
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
            _ = checkStarRepository(type: .unStarRepository)
            btnStar.setImage(UIImage(named: ImageName.icon_button_unstar.rawValue), for: .normal)
            self.view.makeToast("You unstarred \(repositoryItem?.fullname ?? "")")
            print("Did unstarred \(repositoryItem?.fullname ?? "")")
        } else {
            _ = checkStarRepository(type: .starRepository)
            btnStar.setImage(UIImage(named: ImageName.icon_button_star.rawValue), for: .normal)
            self.view.makeToast("You starred \(repositoryItem?.fullname ?? "")")
            print("Did starred \(repositoryItem?.fullname ?? "")")
        }
        isStarred = !isStarred
    }
    
    @IBAction func btnClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnWatches(_ sender: Any) {
        let watchingViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.watchingVC.rawValue) as! WatchingViewController
        watchingViewController.modalPresentationStyle = .automatic
        watchingViewController.getType = .getWatchers
        watchingViewController.repoItem = repositoryItem
        watchingViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
        self.present(watchingViewController, animated:true, completion:nil)
    }
    
    @IBAction func btnStarsCount(_ sender: Any) {
        let starsViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.starVC.rawValue) as! StarViewController
        starsViewController.modalPresentationStyle = .automatic
        starsViewController.repoItem = repositoryItem
        starsViewController.getType = .getStargazers
        starsViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
        self.present(starsViewController, animated:true, completion:nil)
    }
    
    @IBAction func btnForks(_ sender: Any) {
        let forksViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.forkVC.rawValue) as! ForkViewController
        forksViewController.modalPresentationStyle = .automatic
        forksViewController.repoItem = repositoryItem
        forksViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
        self.present(forksViewController, animated:true, completion:nil)
    }
    
    
    
    // MARK: - Private Method
    
    private func getData() {
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
                self?.updateStatus()
            }
            if !errorMessage.isEmpty {
                print("Search error: " + errorMessage)
            }
        }
    }
    
    private func checkStarRepository(type: GetType) -> Bool {
        var isSuccess = false
        repositoryGithubAPI.getResults(type: type, gitHubAuthenticationManager: gitHubAuthenticationManager, fullname: repositoryItem!.fullname!) {results, errorMessage, statusCode in
            if let statusCode = statusCode {
                if statusCode == 204 { isSuccess = true }
            }
            if !errorMessage.isEmpty {
                print("Search error: " + errorMessage)
            }
            
        }
        return isSuccess
    }
    
    private func updateStatus() {
        if gitHubAuthenticationManager.didAuthenticated {
            isStarred = checkStarRepository(type: .checkStarredRepository)
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 1
        } else {
            return repositoryDetails?.count ?? 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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


// MARK: - UITableViewDelegate
extension RepositoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)        
        let itemCell = repositoryDetails?[indexPath.row]
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        print(repositoryDetails?[indexPath.row].id ?? "")
        
        switch itemCell!.id {
        case "homepage":
            if let url = URL(string: repositoryItem?.homepage ?? "") {
                UIApplication.shared.open(url)
            }
        case "issues":            
            let issuesViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.issueVC.rawValue) as! IssueViewController
            issuesViewController.modalPresentationStyle = .automatic
            issuesViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
            issuesViewController.repoItem = repositoryItem
            self.present(issuesViewController, animated:true, completion:nil)
        case "pulls":
            let pullsViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.pullVC.rawValue) as! PullRequestViewController
            pullsViewController.modalPresentationStyle = .automatic
            pullsViewController.repoItem = repositoryItem
            pullsViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
            self.present(pullsViewController, animated:true, completion:nil)
        case "commits":
            let commitsViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.commitVC.rawValue) as! CommitViewController
            commitsViewController.modalPresentationStyle = .automatic
            commitsViewController.repoItem = repositoryItem
            commitsViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
            self.present(commitsViewController, animated:true, completion:nil)
        case "branches":
            let branchesViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.branchVC.rawValue) as! BranchViewController
            branchesViewController.modalPresentationStyle = .automatic
            branchesViewController.repoItem = repositoryItem
            branchesViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
            branchesViewController.delegate = self
            self.present(branchesViewController, animated:true, completion:nil)
        case "releases":
            let releaseViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.releaseVC.rawValue) as! ReleaseViewController
            releaseViewController.modalPresentationStyle = .automatic
            releaseViewController.repoItem = repositoryItem
            releaseViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
            self.present(releaseViewController, animated:true, completion:nil)
        case "contributors":
            let contributorViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.contributorVC.rawValue) as! ContributorViewController
            contributorViewController.modalPresentationStyle = .automatic
            contributorViewController.repoItem = repositoryItem
            contributorViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
            self.present(contributorViewController, animated:true, completion:nil)
        case "events":
            let eventViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.repoEventVC.rawValue) as! RepositoryEventViewController
            eventViewController.modalPresentationStyle = .automatic
            eventViewController.repoItem = repositoryItem
            eventViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
            self.present(eventViewController, animated:true, completion:nil)
            
        default:
            break
        }
    }
}


// MARK: - Delegate

extension RepositoryViewController: BranchViewControllerDelegate {
    
    func branchViewController(_ controller: BranchViewController, didFinishEditing branchSelected: String) {
        self.branch = branchSelected
        resultTableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
}
