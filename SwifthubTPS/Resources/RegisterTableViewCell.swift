//
//  RegisterTableViewCell.swift
//  SwifthubTPS
//
//  Created by TPS on 8/26/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import Foundation
import UIKit

struct TableViewCellIdentifiers {
    static let repositoryTrending = "RepositoryCell"
    static let userTrending = "UserCell"
    static let language = "LanguageCell"
    static let loading = "LoadingCell"
    static let noResult = "NoResultCell"
}

struct RegisterTableViewCell {
    static func register(tableView: UITableView, identifier: String) {
        let cellNib = UINib(nibName: identifier, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: identifier)
    }
}
