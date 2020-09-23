//
//  RegisterTableViewCell.swift
//  SwifthubTPS
//
//  Created by TPS on 8/26/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import Foundation
import UIKit

enum CellIdentifiers: String {
    case repositoryCell = "RepositoryCell"
    case userCell = "UserCell"
    case languageCell = "LanguageCell"
    case loadingCell = "LoadingCell"
    case noResultCell = "NoResultCell"
    case detailCell = "DetailCell"
    case issueCell = "IssueCell"
    case pullRequestCell = "PullRequestCell"
    case commitCell = "CommitCell"
    case releaseCell = "ReleaseCell"
    case contributorCell = "ContributorCell"
    case eventCell = "EventCell"
    case notificationCell = "NotificationCell"
    case contentCell = "ContentCell"
    case languageChartCell = "LanguageChartCell"
    case languageCollectionCell = "LanguageCollectionCell"
}

struct RegisterTableViewCell {
    static func register(tableView: UITableView, identifier: String) {
        let cellNib = UINib(nibName: identifier, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: identifier)
    }
}

struct RegisterCollectionViewCell {
    static func register(collectionView: UICollectionView, identifier: String) {
        let cellNib = UINib(nibName: identifier, bundle: nil)
        collectionView.register(cellNib, forCellWithReuseIdentifier: identifier)
    }
}
