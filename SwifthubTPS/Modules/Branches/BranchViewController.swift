//
//  BranchViewController.swift
//  SwifthubTPS
//
//  Created by TPS on 9/4/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import UIKit

protocol BranchViewControllerDelegate: class {
    func branchViewController(_ controller: BranchViewController, didFinishEditing branchSelected: String)
}

class BranchViewController: UIViewController {

    // MARK: - Properties
    
    weak var delegate: BranchViewControllerDelegate?
    var repoItem: Repository?
    var gitHubAuthenticationManager = GITHUB()
    private var isLoading = false
    private var noResult = false
    private var branchGithubAPI = GitHubAPI<Branch>()
    private var branchItems: [Branch]?
    
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var resultTableView: UITableView!
    
    
    // MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = repoItem?.fullname!
        updateTableView()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ///Register cell
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.detailCell.rawValue)
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.loadingCell.rawValue)
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.noResultCell.rawValue)
    }
    
    // MARK: - IBActions
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Private Method
   
    private func updateTableView(){
        isLoading = true
        resultTableView.reloadData()
        noResult = false
        
        branchGithubAPI.getResults(type: .getBranches, gitHubAuthenticationManager: gitHubAuthenticationManager, fullname: repoItem?.fullname ?? "") { [weak self] results, errorMessage, statusCode in
            if let results = results {
                if results.count == 0 {
                    self?.noResult = true
                    self?.isLoading = false
                } else {
                    self?.branchItems = results
                    self?.isLoading = false
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

extension BranchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading || noResult {
            return 1
        } else {
            return branchItems?.count ?? 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
                  let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loadingCell.rawValue, for: indexPath)
                  let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
                  spinner.startAnimating()
                  return cell
        } else if noResult {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.noResultCell.rawValue, for: indexPath)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.detailCell.rawValue, for: indexPath) as! DetailCell
            
            cell.imgCell?.image = UIImage(named: ImageName.icon_cell_git_branch.rawValue)
            cell.lbTitleCell.text = branchItems![indexPath.row].name
            cell.lbDetails.isHidden = true
            return cell
        }
    }
    
    
}

// MARK: - UITableViewDelegate

extension BranchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! DetailCell
        delegate?.branchViewController(self, didFinishEditing: cell.lbTitleCell.text!)
    }
}

