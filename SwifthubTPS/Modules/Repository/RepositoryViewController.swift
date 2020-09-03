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
                if let smallURL = URL(string: self?.repositoryItem?.owner?.avatarUrl ?? "") {
                    self?.downloadTask = self?.imgAvatar.loadImage(url: smallURL)
                }
                self?.lbDescription.text = self?.repositoryItem?.description
                self?.lbWatches.text = "\(self?.repositoryItem?.subscribersCount ?? 0)"
                self?.lbStars.text = "\(self?.repositoryItem?.stargazersCount ?? 0)"
                self?.lbForks.text = "\(self?.repositoryItem?.forks ?? 0)"
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
        return repositoryDetails?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.detailCell.rawValue, for: indexPath) as! DetailCell

        let itemCell = repositoryDetails?[indexPath.row]
        cell.lbTitleCell.text = itemCell?.titleCell
        cell.lbDetails.text = itemCell?.detail
        if let img = itemCell?.imgName {
            cell.imgCell.image = UIImage(named: img)
        }        
        cell.imgDisclosure.isHidden = (itemCell?.hideDisclosure ?? false)
        
        return cell
    }
    
    
}


// MARK: - UITableViewDelegate
extension RepositoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)        
        
        print(repositoryDetails?[indexPath.row].id ?? "")
    }
}

