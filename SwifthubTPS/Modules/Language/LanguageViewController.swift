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
    
    weak var delegate: LanguageViewControllerDelegate?
    var languageItem: Language!
    
    var languages: [Language]?
    var cellChecked = IndexPath(row: -1, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btnAllLanguage.layer.cornerRadius = 5
        RegisterTableViewCell.register(tableView: languageTableView, identifier: TableViewCellIdentifiers.language)
        
        languages = TrendingGithubAPI.getDatas(type: .language)
        
    }
    
    @IBAction func btnClose(_ sender: Any) {
        delegate?.languageViewControllerDidCancel(self)
    }
    @IBAction func btnSave(_ sender: Any) {
        if cellChecked.row != -1 {
            languageItem = languages?[cellChecked.row]
        }
        delegate?.languageViewController(self, didFinishEditing: languageItem)
    }
    
    @IBAction func btnAllLanguage(_ sender: Any) {
    }
    
   
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


// MARK:- Table View Cell
   
extension LanguageViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.language, for: indexPath) as! LanguageCell
        cell.lbLanguage.text = languages![indexPath.row].name
        cell.imgCheck.isHidden = true
        return cell
    }
   
}


extension LanguageViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if cellChecked.row != -1, let cell = tableView.cellForRow(at: cellChecked) as? LanguageCell{
            cell.imgCheck.isHidden = true
        }
        if let cell = tableView.cellForRow(at: indexPath) as? LanguageCell{
            cell.imgCheck.isHidden = false
            cellChecked = indexPath
        }
    }
}
