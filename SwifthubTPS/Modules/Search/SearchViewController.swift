//
//  FirstViewController.swift
//  SwifthubTPS
//
//  Created by TPS on 8/24/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import UIKit
//import HMSegmentedControl
import UIColor_Hex_Swift

class SearchViewController: UIViewController {

    
    @IBOutlet weak var resultTableView: UITableView!
    @IBOutlet weak var typeApiSegmentControl: UISegmentedControl!
    @IBOutlet weak var sinceApiSegmentControl: UISegmentedControl!
    
    var downloadTask: URLSessionDownloadTask?
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
                print("Got results: \(item.fullname ?? "")")
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
        cell.lbStars.text = roundedValue(value: trendingRepositories![indexPath.row].stars!)
        cell.lbCurrentPeriodStars.text = roundedValue(value: trendingRepositories![indexPath.row].currentPeriodStars!)
        cell.lbLanguage.isHidden = false
       // cell.viewLanguageColor.isHidden = false
        cell.lbLanguage.text = trendingRepositories![indexPath.row].language
        if let color = trendingRepositories![indexPath.row].languageColor {
            cell.viewLanguageColor.backgroundColor = UIColor(color)
        } else {
            cell.viewLanguageColor.isHidden = true
            cell.lbLanguage.isHidden = true
        }
        cell.imgAuthor.image = UIImage(named: "Placeholder")
        if let smallURL = URL(string: (trendingRepositories?[indexPath.row].avatarUrl!)!) {
            downloadTask = cell.imgAuthor.loadImage(url: smallURL)
        }
        return cell
    }
    
}

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
}

// MARK:- Helper Methods

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension SearchViewController {
    
    func roundedValue(value: Int) -> String {
        if value < 1000 {
            return String(value)
        } else {
            let temp = (Double(value)/1000).rounded(toPlaces: 1)
            return String(temp) + "k"
        }
    }
    
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



