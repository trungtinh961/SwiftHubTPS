//
//  FirstViewController.swift
//  SwifthubTPS
//
//  Created by TPS on 8/24/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import UIKit
import HMSegmentedControl

class SearchViewController: UIViewController {

    
    @IBOutlet weak var resultTableView: UITableView!
    @IBOutlet weak var typeApiSegmentControl: UISegmentedControl!
    @IBOutlet weak var sinceApiSegmentControl: UISegmentedControl!
    
    var trendingRepositories: [TrendingRepository]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        RegisterTableViewCell.register(tableView: resultTableView, identifier: TableViewCellIdentifiers.repositoryTrending)
        
        let url = iTunesURL(searchText: "abc xyz")
        print("URL: '\(url)'")
        if let data = performStoreRequest(with: url) {  // Modified
            trendingRepositories = parse(data: data)
            for item in trendingRepositories! {
                print("Got results: \(item.fullname! )")
            }
            
        }
        
    }
    
    // MARK:- Action
    
    @IBAction func btnLanguage(_ sender: Any) {
    }
    
    @IBAction func typeApiSegmentControl(_ sender: Any) {
    }
    
    @IBAction func sinceApiSegmentControl(_ sender: Any) {
    }
}

// MARK:- UI Table View

extension SearchViewController: UITableViewDataSource {
      
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trendingRepositories!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.repositoryTrending, for: indexPath) as! RepositoryCell
        cell.lbFullname.text = trendingRepositories![indexPath.row].fullname
        cell.lbDescription.text = trendingRepositories![indexPath.row].description
        cell.lbStars.text = String(trendingRepositories![indexPath.row].stars!)
        
        return cell
    }
    
}

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
}

// MARK:- Helper Methods



extension SearchViewController {
    
//    func 
    
    func iTunesURL(searchText: String) -> URL {
        let urlString = String(format: "https://ghapi.huchen.dev/repositories")
        let url = URL(string: urlString)
        return url!
    }

    func performStoreRequest(with url: URL) -> Data? {
        do {
            return try Data(contentsOf: url)
        } catch {
            print("Download Error: \(error.localizedDescription)")
            return nil
        }
    }


    func parse(data: Data) -> [TrendingRepository] {
        var jsonArray: Array<Any>!
        do {
            jsonArray = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? Array
        } catch {
          print(error)
        }
        var trendingRepositories = [TrendingRepository]()
        for json in jsonArray {
          if let item = json as? [String: AnyObject] {
            trendingRepositories.append(TrendingRepository(JSON: item)!)
          }
        }
        return trendingRepositories
    }

    func showNetworkError() {
        let alert = UIAlertController(title: "Whoops...", message: "There was an error accessing the iTunes Store." + " Please try again.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        present(alert, animated: true, completion: nil)
        alert.addAction(action)
    }

}



