//
//  RepositoryViewController.swift
//  SwifthubTPS
//
//  Created by TPS on 9/1/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import UIKit

class RepositoryViewController: UIViewController {

    // MARK: - Properties
    
    private var downloadTask: URLSessionDownloadTask?
    var repoFullname: String?
    private var repositoryGithubAPI = GitHubAPI<Repository>()
    private var repositoryItem: Repository?
    private var isLoading = false
    private var repositoryDetails: [DetailCellProperty]?
    private var branch: String?
    
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
    
    
    // MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navItem.title = repoFullname
        getData()
        ///Register cell
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.detailCell.rawValue)
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.loading.rawValue)
        
        
        /// Config layout
        imgAvatar.layer.cornerRadius = imgAvatar.frame.height / 2
        imgAvatar.layer.masksToBounds = true
        watchesView.layer.cornerRadius = 5
        starsView.layer.cornerRadius = 5
        forksView.layer.cornerRadius = 5
    }
    
    // MARK: - IBActions
    
    @IBAction func btnClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    // MARK: - Private Method
    
    private func getData() {
        isLoading = true
        repositoryGithubAPI.getResults(type: .getRepository, fullname: repoFullname!) { [weak self] results, errorMessage in
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
                self?.branch = self?.repositoryItem?.defaultBranch
                self?.repositoryDetails = self?.repositoryItem?.getDetailCell()
                self?.resultTableView.reloadData()
            }
            if !errorMessage.isEmpty {
                print("Search error: " + errorMessage)
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
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loading.rawValue, for: indexPath)
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
            issuesViewController.repoItem = repositoryItem
            self.present(issuesViewController, animated:true, completion:nil)
        case "pulls":
            let pullsViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.pullVC.rawValue) as! PullRequestViewController
            pullsViewController.modalPresentationStyle = .automatic
            pullsViewController.repoItem = repositoryItem
            self.present(pullsViewController, animated:true, completion:nil)
        case "commits":
            let commitsViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.commitVC.rawValue) as! CommitViewController
            commitsViewController.modalPresentationStyle = .automatic
            commitsViewController.repoItem = repositoryItem
            self.present(commitsViewController, animated:true, completion:nil)
        case "branches":
            let branchesViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.branchVC.rawValue) as! BranchViewController
            branchesViewController.modalPresentationStyle = .automatic
            branchesViewController.repoItem = repositoryItem
            branchesViewController.delegate = self
            self.present(branchesViewController, animated:true, completion:nil)
        case "releases":
            let releaseViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.releaseVC.rawValue) as! ReleaseViewController
            releaseViewController.modalPresentationStyle = .automatic
            releaseViewController.repoItem = repositoryItem            
            self.present(releaseViewController, animated:true, completion:nil)
        case "contributors":
            let contributorViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.contributorVC.rawValue) as! ContributorViewController
            contributorViewController.modalPresentationStyle = .automatic
            contributorViewController.repoItem = repositoryItem
            self.present(contributorViewController, animated:true, completion:nil)
        case "events":
            let eventViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.eventVC.rawValue) as! EventViewController
            eventViewController.modalPresentationStyle = .automatic
            eventViewController.repoItem = repositoryItem
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
