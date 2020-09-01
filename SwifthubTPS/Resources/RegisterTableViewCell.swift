//
//  RegisterTableViewCell.swift
//  SwifthubTPS
//
//  Created by TPS on 8/26/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import Foundation
import UIKit

enum TableViewCellIdentifiers: String {
    case repositoryTrending = "RepositoryCell"
    case userTrending = "UserCell"
    case language = "LanguageCell"
    case loading = "LoadingCell"
    case noResult = "NoResultCell"
    case detailCell = "DetailCell"
}

struct RegisterTableViewCell {
    static func register(tableView: UITableView, identifier: String) {
        let cellNib = UINib(nibName: identifier, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: identifier)
    }
}
