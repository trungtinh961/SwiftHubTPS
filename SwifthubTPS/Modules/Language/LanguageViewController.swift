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

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var languageTableView: UITableView!
    @IBOutlet weak var btnAllLanguage: UIButton!
    @IBOutlet weak var btnSave: UIBarButtonItem!
    
    weak var delegate: LanguageViewControllerDelegate?
    var languageItem: Language!
    var language: String?
    var languages: [Language]?
    var cellChecked = IndexPath(row: -1, section: 0)
    var isLoading = false
    var isFirstLaunch = true
    
    func updateTableView(language: String? = "") {
        isLoading = true
        let queue = DispatchQueue.global()
        queue.async {
            
            self.languages = TrendingGithubAPI.getDatas(type: .language)
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.languageTableView.reloadData()
                self.selectCell()
            }
        }
    }
    
    func selectCell() {
        if language != nil, languages != nil {
            for index in 0..<languages!.count {
                if language == languages![index].urlParam {
                    cellChecked = IndexPath(row: index, section: 0)
                    break
                }
            }
            tableView(languageTableView, didSelectRowAt: cellChecked)
            languageTableView.scrollToRow(at: cellChecked, at: .middle, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTableView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        /// Register Cell
        
        RegisterTableViewCell.register(tableView: languageTableView, identifier: TableViewCellIdentifiers.language)
        RegisterTableViewCell.register(tableView: languageTableView, identifier: TableViewCellIdentifiers.loading)

        /// Config layouts
        btnAllLanguage.layer.cornerRadius = 5
        btnSave.isEnabled = false
        isFirstLaunch = false
        
    }
    
    @IBAction func btnClose(_ sender: Any) {
        delegate?.languageViewControllerDidCancel(self)
    }
    @IBAction func btnSave(_ sender: Any) {
        if cellChecked.row != -1 {
            languageItem = languages?[cellChecked.row]
            delegate?.languageViewController(self, didFinishEditing: languageItem)
        }
    }
    
    @IBAction func btnAllLanguage(_ sender: Any) {
        delegate?.languageViewControllerDidCancel(self)
    }
    
   
}


// MARK:- Table View Cell
   
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
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loading, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.language, for: indexPath) as! LanguageCell
            cell.lbLanguage.text = languages![indexPath.row].name
            cell.imgCheck.isHidden = true
            if !isFirstLaunch, indexPath == cellChecked {
                cell.imgCheck.isHidden = false
            }
            return cell
        }
        
    }
   
}


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
