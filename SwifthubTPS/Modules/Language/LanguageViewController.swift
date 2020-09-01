//
//  LanguageViewController.swift
//  SwifthubTPS
//
//  Created by TPS on 8/28/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import UIKit

protocol LanguageViewControllerDelegate: class {
    func languageViewControllerDidCancel(_ controller: LanguageViewController)
    func languageViewController(_ controller: LanguageViewController, didFinishEditing item: Language)
}

class LanguageViewController: UIViewController {

    //MARK: - Properties
    
    weak var delegate: LanguageViewControllerDelegate?
    private var trendingLanguageGithubAPI = TrendingGithubAPI<Language>()
    private var languageItem: Language!
    var language: String?
    private var languages: [Language]?
    private var cellChecked = IndexPath(row: -1, section: 0)
    private var isLoading = false
    private var isFirstLaunch = true
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var languageTableView: UITableView!
    @IBOutlet weak var btnAllLanguage: UIButton!
    @IBOutlet weak var btnSave: UIBarButtonItem!
    
    //MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTableView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        /// Register Cell
        
        RegisterTableViewCell.register(tableView: languageTableView, identifier: TableViewCellIdentifiers.language.rawValue)
        RegisterTableViewCell.register(tableView: languageTableView, identifier: TableViewCellIdentifiers.loading.rawValue)

        /// Config layouts
        btnAllLanguage.layer.cornerRadius = 5
        btnSave.isEnabled = false
        isFirstLaunch = false
        
    }
    
    //MARK: - IBActions
    
    @IBAction func btnClose(_ sender: Any) {
        delegate?.languageViewControllerDidCancel(self)
    }
    @IBAction func btnSave(_ sender: Any) {
        isFirstLaunch = false
        if cellChecked.row != -1 {
            languageItem = languages?[cellChecked.row]
            delegate?.languageViewController(self, didFinishEditing: languageItem)
        }
    }
    
    @IBAction func btnAllLanguage(_ sender: Any) {
        delegate?.languageViewControllerDidCancel(self)
    }
    
    // MARK: - Public method
    
    func updateTableView(language: String? = "") {
        isLoading = true
        
        trendingLanguageGithubAPI.getResults(type: .language) { [weak self] results, errorMessage in
            if let results = results {
                self?.languages = results
                self?.isLoading = false
                self?.languageTableView.reloadData()
                self?.selectCell()
            }

            if !errorMessage.isEmpty {
                print("Search error: " + errorMessage)
            }
        }
    }
    
    func selectCell() {
        if language != nil, languages != nil {
            for index in 0..<languages!.count {
                if language == languages![index].urlParam?.removingPercentEncoding {
                    cellChecked = IndexPath(row: index, section: 0)
                    break
                }
            }
            tableView(languageTableView, didSelectRowAt: cellChecked)
            languageTableView.scrollToRow(at: cellChecked, at: .middle, animated: true)
        }
    }
   
}


// MARK:- UITableViewDataSource
   
extension LanguageViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 1
        } else {
            return languages!.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loading.rawValue, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.language.rawValue, for: indexPath) as! LanguageCell
            cell.lbLanguage.text = languages![indexPath.row].name
            cell.imgCheck.isHidden = true
            if !isFirstLaunch, indexPath == cellChecked {
                cell.imgCheck.isHidden = false
            }
            return cell
        }
        
    }
   
}

// MARK:- UITableViewDelegate

extension LanguageViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if !isFirstLaunch, cellChecked.row != -1, let cell = tableView.cellForRow(at: cellChecked) as? LanguageCell{
            cell.imgCheck.isHidden = true
        }
        if let cell = tableView.cellForRow(at: indexPath) as? LanguageCell{
            isFirstLaunch = false
            cell.imgCheck.isHidden = false
            cellChecked = indexPath
        }
        btnSave.isEnabled = true
    }
}
