//
//  LanguageChartCell.swift
//  SwifthubTPS
//
//  Created by TPS on 9/16/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import UIKit

class LanguageChartCell: UITableViewCell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var repositoryItem: Repository?
    private var repositoryLanguages: [String:Int] = [:]
    private var colorLanguages: [String: ColorLanguage] = [:]
    private var results: [ChartLanguage] = []
    private var colorURL: String = "https://raw.githubusercontent.com/ozh/github-colors/master/colors.json"
    private var languageURL: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.layer.cornerRadius = 5
        chartView.layer.cornerRadius = 5
        self.collectionView.register(UINib.init(nibName: "LanguageCollectionCell", bundle: nil), forCellWithReuseIdentifier: "LanguageCollectionCell")
        getColorLanguage()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func getRepositoryLanguages() {
        languageURL = "https://api.github.com/repos/\(repositoryItem!.fullname!)/languages"
        let url = URL(string: languageURL)
        var request = URLRequest(url: url!)
        request.setValue("application/vnd.github.v3.raw", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    self.repositoryLanguages = try JSONDecoder().decode([String:Int].self, from: data)
                    for (key, value) in self.repositoryLanguages {
                        self.results.append(ChartLanguage(name: key, color: self.colorLanguages[key]?.color, quantity: value))
                    }
                    self.results.sort(by: { $0.quantity > $1.quantity } )
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                } catch {
                    print("Language \(error)")
                }
            }
        }.resume()
    }
    
    private func getColorLanguage() {
        let url = URL(string: colorURL)
        let request = URLRequest(url: url!)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    self.colorLanguages = try JSONDecoder().decode([String:ColorLanguage].self, from: data)
                    self.getRepositoryLanguages()
                } catch {
                    print("Color \(error)")
                }
            }
        }.resume()
    }
    
}

extension LanguageChartCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LanguageCollectionCell", for: indexPath as IndexPath) as! LanguageCollectionCell
        cell.lbLanguageName.text = results[indexPath.row].name
        cell.languageColorView.backgroundColor = UIColor(results[indexPath.row].color ?? "#AFEDFC")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let label = UILabel()
            label.text = results[indexPath.row].name
            label.sizeToFit()
            let size = CGSize(width: label.frame.size.width + 10, height: 36)
            return size
    }
}
