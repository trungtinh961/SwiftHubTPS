//
//  LanguageChartCell.swift
//  SwifthubTPS
//
//  Created by TPS on 9/16/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import UIKit
import MultiProgressView

class LanguageChartCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Public Properties
    var gitHubAuthenticationManager = GITHUB()
    var repositoryItem: Repository?
    
    // MARK: - Private Properties
    private var repositoryLanguages: [String:Int] = [:]
    private var colorLanguages: [String: ColorLanguage] = [:]
    private var results: [ChartLanguage] = []
    private var colorURL: String = "https://raw.githubusercontent.com/ozh/github-colors/master/colors.json"
    private var languageURL: String = ""
    private let padding: CGFloat = 15
    private let progressViewHeight: CGFloat = 20
    private var totalLines = 0
    
    private lazy var progressView: MultiProgressView = {
      let progress = MultiProgressView()
      progress.lineCap = .round
      progress.cornerRadius = progressViewHeight / 4
      return progress
    }()
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.layer.cornerRadius = 5
        
        self.collectionView.register(UINib.init(nibName: "LanguageCollectionCell", bundle: nil), forCellWithReuseIdentifier: "LanguageCollectionCell")
        getColorLanguage()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    // MARK: - Private Methods
    
    /// Progressbar
    private func setupProgressBar() {
        chartView.addSubview(progressView)
        progressView.frame = CGRect(x: 0,
                                    y: 0,
                                    width: chartView.frame.width - 0,
                                    height: chartView.frame.height - 8)
        progressView.dataSource = self
        progressView.delegate = self
    }
    
    private func setProgress() {
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0,
                       options: .curveLinear,
                       animations: {
                        for (index, language) in self.results.enumerated() {
                            let percentage = Float(language.linesOfCode) / Float(self.totalLines)
                            self.progressView.setProgress(section: index, to: percentage)
                        }
        })
    }
    
    private func noLanguage() {
        let lbNoLanguage = UILabel()
        lbNoLanguage.frame = CGRect(x: 8,
                                    y: 0,
                                    width: chartView.frame.width - 8,
                                    height: chartView.frame.height)
        lbNoLanguage.center = CGPoint(x: mainView.frame.size.width  / 2,
                                      y: mainView.frame.size.height / 2)
        lbNoLanguage.text = "No language found."
        lbNoLanguage.textColor = .darkGray
        mainView.addSubview(lbNoLanguage)
    }
    
    /// Get data
    private func getColorLanguage() {
        let url = URL(string: colorURL)
        let request = URLRequest(url: url!)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    DispatchQueue.main.async {
                        self.setupProgressBar()
                    }
                    self.colorLanguages = try JSONDecoder().decode([String:ColorLanguage].self, from: data)
                    self.getRepositoryLanguages()
                } catch {
                    print("Color \(error)")
                }
            }
        }.resume()
    }
    
    private func getRepositoryLanguages() {
        languageURL = "https://api.github.com/repos/\(repositoryItem!.fullname!)/languages"
        let url = URL(string: languageURL)
        var request = URLRequest(url: url!)
        if gitHubAuthenticationManager.didAuthenticated {
            request.setValue("token \(gitHubAuthenticationManager.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        }
        request.setValue("application/vnd.github.v3.raw", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {                    
                    self.repositoryLanguages = try JSONDecoder().decode([String:Int].self, from: data)
                    for (key, value) in self.repositoryLanguages {
                        self.results.append(ChartLanguage(name: key, color: self.colorLanguages[key]?.color, linesOfCode: value))
                        self.totalLines += value
                    }
                    self.results.sort(by: { $0.linesOfCode > $1.linesOfCode } )
                    DispatchQueue.main.async {
                        if self.results.count == 0 {
                            self.noLanguage()
                        } else {
                            self.collectionView.reloadData()
                            self.progressView.reloadData()
                            self.setProgress()
                        }
                    }
                } catch {
                    print("Language \(error)")
                }
            }
        }.resume()
    }
    
}

// MARK: - UICollectionViewDataSource
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

// MARK: - MultiProgressViewDataSource
extension LanguageChartCell: MultiProgressViewDataSource {
    func numberOfSections(in progressView: MultiProgressView) -> Int {
        return results.count
    }
    
    func progressView(_ progressView: MultiProgressView, viewForSection section: Int) -> ProgressViewSection {
        let bar = ProgressViewSection()
        bar.backgroundColor = UIColor(results[section].color ?? "#AFEDFC")
        return bar
    }
}

// MARK: - MultiProgressViewDelegate
extension LanguageChartCell: MultiProgressViewDelegate {
    func progressView(_ progressView: MultiProgressView, didTapSectionAt index: Int) {
        print("Tapped section \(index)")
    }
}
