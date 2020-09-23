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
    func allLanguageViewController(_ controller: LanguageViewController)
}

class LanguageViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var languageTableView: UITableView!
    @IBOutlet weak var btnAllLanguage: UIButton!
    @IBOutlet weak var btnSave: UIBarButtonItem!
    @IBOutlet weak var lbLanguageName: UILabel!
    
    // MARK: - Public properties
    var language: String?
    weak var delegate: LanguageViewControllerDelegate?
    
    // MARK: - Private properties
    private var trendingLanguageGithubAPI = TrendingGithubAPI<Language>()
    private var languageItem: Language!
    private var languages: [Language]?
    private var cellChecked = IndexPath(row: -1, section: 0)
    private var isLoading = false
    private var noResult = false
    private var isFirstLaunch = true
    
    //MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTableView()
        makeUI()
    }
    
    private func makeUI() {
        self.hideKeyboardWhenTappedAround()
        lbLanguageName.text = "All"
        /// Register Cell
        RegisterTableViewCell.register(tableView: languageTableView, identifier: CellIdentifiers.languageCell.rawValue)
        RegisterTableViewCell.register(tableView: languageTableView, identifier: CellIdentifiers.loadingCell.rawValue)
        RegisterTableViewCell.register(tableView: languageTableView, identifier: CellIdentifiers.noResultCell.rawValue)
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
        delegate?.allLanguageViewController(self)
    }
    
    // MARK: - Private Method
    private func updateTableView(language: String? = "") {
        isLoading = true
        languageTableView.reloadData()
        noResult = false
        
        trendingLanguageGithubAPI.getResults(type: .language)
        { [weak self] results, errorMessage in
            if let results = results {
                if results.count == 0 {
                    self?.noResult = true
                    self?.isLoading = false
                } else {
                    self?.languages = results
                    self?.isLoading = false
                }
                self?.languageTableView.reloadData()
                self?.selectCell()
            }
            if !errorMessage.isEmpty {
                debugPrint(errorMessage)
            }
        }
    }
    
    private func selectCell() {
        if language != nil, languages != nil {
            for index in 0..<languages!.count {
                if language == languages![index].urlParam?.removingPercentEncoding {
                    lbLanguageName.text = languages![index].name
                    cellChecked = IndexPath(row: index, section: 0)
                    break
                }
            }
            tableView(languageTableView, didSelectRowAt: cellChecked)
            languageTableView.scrollToRow(at: cellChecked, at: .middle, animated: true)
        }
    }
   
}


// MARK: - UITableViewDataSource
extension LanguageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading || noResult {
            return 1
        } else {
            return languages!.count
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
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.languageCell.rawValue, for: indexPath) as! LanguageCell
            cell.lbLanguage.text = languages![indexPath.row].name
            cell.imgCheck.isHidden = true
            if !isFirstLaunch, indexPath == cellChecked {
                cell.imgCheck.isHidden = false
            }
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension LanguageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if !isLoading, !noResult {
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
}
