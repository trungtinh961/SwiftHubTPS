//
//  Repository.swift
//  SwifthubTPS
//
//  Created by TPS on 8/26/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import Foundation
import ObjectMapper

struct Repository: Mappable {
    
    var createdAt: Date?
    var defaultBranch = "master"
    var description: String?
    var forks: Int?
    var fullname: String?
    var homepage: String?
    var language: String?
    var languageColor: String?
    var htmlUrl: String?
    var name: String?
    var openIssuesCount: Int?
    var owner: User?
    var size: Int?
    var stargazersCount: Int?
    var subscribersCount: Int?
    var updatedAt: Date?

    var commitsCount: Int?
    var pullRequestsCount: Int?
    var releasesCount: Int?
    var contributorsCount: Int?
    var viewerHasStarred: Bool?

    init?(map: Map) {}
    init() {}

    init(name: String?, fullname: String?, description: String?, language: String?, languageColor: String?, stargazers: Int?, viewerHasStarred: Bool?, ownerAvatarUrl: String?) {
        self.name = name
        self.fullname = fullname
        self.description = description
        self.language = language
        self.languageColor = languageColor
        self.stargazersCount = stargazers
        self.viewerHasStarred = viewerHasStarred
        owner = User()
        owner?.avatarUrl = ownerAvatarUrl
    }

    init(repo: TrendingRepository) {
        self.init(name: repo.name, fullname: repo.fullname, description: repo.description,
                  language: repo.language, languageColor: repo.languageColor, stargazers: repo.stars,
                  viewerHasStarred: nil, ownerAvatarUrl: repo.builtBy?.first?.avatar)
    }

    mutating func mapping(map: Map) {
        createdAt <- (map["created_at"], ISO8601DateTransform())
        defaultBranch <- map["default_branch"]
        description <- map["description"]
        forks <- map["forks"]
        fullname <- map["full_name"]
        homepage <- map["homepage"]
        htmlUrl <- map["html_url"]
        language <- map["language"]
        name <- map["name"]
        openIssuesCount <- map["open_issues_count"]
        owner <- map["owner"]
        size <- map["size"]
        stargazersCount <- map["stargazers_count"]
        subscribersCount <- map["subscribers_count"]
        updatedAt <- (map["updated_at"], ISO8601DateTransform())
    }
}

extension Repository: Equatable {
    static func == (lhs: Repository, rhs: Repository) -> Bool {
        return lhs.fullname == rhs.fullname
    }
}

struct RepositorySearch: Mappable {

    var items: [Repository] = []
    var totalCount: Int = 0
    var incompleteResults: Bool = false
    var hasNextPage: Bool = false
    var endCursor: String?

    init?(map: Map) {}
    init() {}    

    mutating func mapping(map: Map) {
        items <- map["items"]
        totalCount <- map["total_count"]
        incompleteResults <- map["incomplete_results"]
        hasNextPage = !items.isEmpty
    }
}


struct TrendingRepository: Mappable {
        
    var author: String?
    var name: String?
    var url: String?
    var description: String?
    var language: String?
    var languageColor: String?
    var stars: Int?
    var forks: Int?
    var currentPeriodStars: Int?
    var builtBy: [TrendingUser]?
    
    var fullname: String? {
        return "\(author ?? "")/\(name ?? "")"
    }
    
    var avatarUrl: String? {
        return builtBy?.first?.avatar
    }
    
    init() {}
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        author <- map["author"]
        name <- map["name"]
        url <- map["url"]
        description <- map["description"]
        language <- map["language"]
        languageColor <- map["languageColor"]
        stars <- map["stars"]
        forks <- map["forks"]
        currentPeriodStars <- map["currentPeriodStars"]
        builtBy <- map["builtBy"]
    }
}


extension Repository {
    func getDetailCell() -> [DetailCellProperty] {
        var detailCellProperties: [DetailCellProperty] = []
        if let language = self.language {
            detailCellProperties.append(DetailCellProperty(imgName: ImageName.icon_cell_git_language.rawValue, titleCell: "Language", detail: language, hideDisclosure: true))
        }
        if let size = self.size {
            detailCellProperties.append(DetailCellProperty(imgName: ImageName.icon_cell_size.rawValue, titleCell: "Size", detail: size.sizeFromKB(), hideDisclosure: true))
        }
        if let created = self.createdAt {
            detailCellProperties.append(DetailCellProperty(imgName: ImageName.icon_cell_created.rawValue, titleCell: "Created", detail: created.toRelative(), hideDisclosure: true))
        }
        if let updated = self.updatedAt {
            detailCellProperties.append(DetailCellProperty(imgName: ImageName.icon_cell_updated.rawValue, titleCell: "Updated", detail: updated.toRelative(), hideDisclosure: true))
        }
        if let homepage = self.homepage, homepage != "" {
            detailCellProperties.append(DetailCellProperty(id: "homepage", imgName: ImageName.icon_cell_link.rawValue, titleCell: "Homepage", detail: homepage, hideDisclosure: false))
        }
        
        detailCellProperties.append(DetailCellProperty(id: "issues", imgName: ImageName.icon_cell_issues.rawValue, titleCell: "Issues", detail: self.openIssuesCount?.kFormatted() ?? "", hideDisclosure: false))
        
        detailCellProperties.append(DetailCellProperty(id: "pulls", imgName: ImageName.icon_cell_git_pull_request.rawValue, titleCell: "Pull Requests", hideDisclosure: false))
        
        detailCellProperties.append(DetailCellProperty(id: "commits", imgName: ImageName.icon_cell_git_commit.rawValue, titleCell: "Commits", hideDisclosure: false))

        detailCellProperties.append(DetailCellProperty(id: "branches", imgName: ImageName.icon_cell_git_branch.rawValue, titleCell: "Branches", detail: defaultBranch, hideDisclosure: false))

        detailCellProperties.append(DetailCellProperty(id: "releases", imgName: ImageName.icon_cell_releases.rawValue, titleCell: "Releases", hideDisclosure: false))
        
        detailCellProperties.append(DetailCellProperty(id: "contributors", imgName: ImageName.icon_cell_company.rawValue, titleCell: "Contributors", hideDisclosure: false))
        
        detailCellProperties.append(DetailCellProperty(id: "events", imgName: ImageName.icon_cell_releases.rawValue, titleCell: "Events", hideDisclosure: false))
        
        detailCellProperties.append(DetailCellProperty(id: "contents", imgName: ImageName.icon_cell_dir.rawValue, titleCell: "Source code", hideDisclosure: false))
        
        return detailCellProperties
    }
}

