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
        navItem.title = repoFullname!
        getData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ///Register cell
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.detailCell.rawValue)
        
        
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
    
    
    
    // MARK: - Public methods
    
    func getData() {
        isLoading = true
        repositoryGithubAPI.getResults(type: .getRepository, fullname: repoFullname!) { [weak self] results, errorMessage in
            if let result = results {
                self?.repositoryItem = result
                self?.isLoading = false
                self?.resultTableView.reloadData()
                if let smallURL = URL(string: self?.repositoryItem?.owner?.avatarUrl ?? "") {
                    self?.downloadTask = self?.imgAvatar.loadImage(url: smallURL)
                }
                self?.lbDescription.text = self?.repositoryItem?.description
                self?.lbWatches.text = "\(self?.repositoryItem?.subscribersCount ?? 0)"
                self?.lbStars.text = "\(self?.repositoryItem?.stargazersCount ?? 0)"
                self?.lbForks.text = "\(self?.repositoryItem?.forks ?? 0)"
                print(self!.repositoryItem?.updatedAt!.timeAgo() ?? 0)
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
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.detailCell.rawValue, for: indexPath) as! DetailCell
        switch indexPath.row {
        case 0:
            cell.lbTypeCell.text = "Languages"
            cell.lbDetails.text = repositoryItem?.language ?? ""
            cell.imgCell.image = UIImage(named: ImageName.icon_cell_created.rawValue)
            cell.imgDisclosure.isHidden = true
        case 1:
            cell.lbTypeCell.text = "Issues"
            cell.lbDetails.text = "\(repositoryItem?.openIssuesCount ?? 0)"
            cell.imgCell.image = UIImage(named: ImageName.icon_cell_issues.rawValue)
            cell.imgDisclosure.isHidden = true
        case 2:
            cell.lbTypeCell.text = "Created"
            cell.lbDetails.text = ""
            cell.imgCell.image = UIImage(named: ImageName.icon_cell_created.rawValue)
            cell.imgDisclosure.isHidden = true
        case 3:
            cell.lbTypeCell.text = "Updated"
            cell.lbDetails.text = ""
            cell.imgCell.image = UIImage(named: ImageName.icon_cell_updated.rawValue)
            cell.imgDisclosure.isHidden = true
//        case 4:
//
//        case 5:
//
//        case 6:
//
//        case 7:
//
//        case 8:
//
//        case 9:
//
//
        default: break
        }
        
        
        
        
        return cell
    }
    
    
}


// MARK: -
extension RepositoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}

