//
//  User.swift
//  SwifthubTPS
//
//  Created by TPS on 8/26/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import Foundation
import ObjectMapper

enum UserType: String {
    case user = "User"
    case organization = "Organization"
}

/// User model
struct User: Mappable {

    var avatarUrl: String?  // A URL pointing to the user's public avatar.
    var blog: String?  // A URL pointing to the user's public website/blog.
    var company: String?  // The user's public profile company.
    var contributions: Int?
    var createdAt: Date?  // Identifies the date and time when the object was created.
    var email: String?  // The user's publicly visible profile email.
    var followers: Int?  // Identifies the total count of followers.
    var following: Int? // Identifies the total count of following.
    var htmlUrl: String?  // The HTTP URL for this user
    var location: String?  // The user's public profile location.
    var login: String?  // The username used to login.
    var name: String?  // The user's public profile name.
    var type: UserType = .user
    var updatedAt: Date?  // Identifies the date and time when the object was last updated.
    var starredRepositoriesCount: Int?  // Identifies the total count of repositories the user has starred.
    var repositoriesCount: Int?  // Identifies the total count of repositories that the user owns.
    var issuesCount: Int?  // Identifies the total count of issues associated with this user
    var watchingCount: Int?  // Identifies the total count of repositories the given user is watching
    var viewerCanFollow: Bool?  // Whether or not the viewer is able to follow the user.
    var viewerIsFollowing: Bool?  // Whether or not this user is followed by the viewer.
    var isViewer: Bool?  // Whether or not this user is the viewing user.
    var pinnedRepositories: [Repository]?  // A list of repositories this user has pinned to their profile
    var organizations: [User]?  // A list of organizations the user belongs to.
    
    // Only for Organization type
    var descriptionField: String?

    // Only for User type
    var bio: String?  // The user's public profile bio.
   
    init?(map: Map) {}
    init() {}

    init(login: String?, name: String?, avatarUrl: String?, followers: Int?, viewerCanFollow: Bool?, viewerIsFollowing: Bool?) {
        self.login = login
        self.name = name
        self.avatarUrl = avatarUrl
        self.followers = followers
        self.viewerCanFollow = viewerCanFollow
        self.viewerIsFollowing = viewerIsFollowing
    }

    init(user: TrendingUser) {
        self.init(login: user.username, name: user.name, avatarUrl: user.avatar, followers: nil, viewerCanFollow: nil, viewerIsFollowing: nil)
        switch user.type {
        case .user: self.type = .user
        case .organization: self.type = .organization
        }
    }

    mutating func mapping(map: Map) {
        avatarUrl <- map["avatar_url"]
        blog <- map["blog"]
        company <- map["company"]
        contributions <- map["contributions"]
        createdAt <- (map["created_at"], ISO8601DateTransform())
        descriptionField <- map["description"]
        email <- map["email"]
        followers <- map["followers"]
        following <- map["following"]
        htmlUrl <- map["html_url"]
        location <- map["location"]
        login <- map["login"]
        name <- map["name"]
        repositoriesCount <- map["public_repos"]
        type <- map["type"]
        updatedAt <- (map["updated_at"], ISO8601DateTransform())
        bio <- map["bio"]
    }
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.login == rhs.login
    }
}

/// UserSearch model
struct UserSearch: Mappable {

    var items: [User] = []
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


enum TrendingUserType: String {
    case user
    case organization
}

struct TrendingUser: Mappable {
       
    var username: String?
    var name: String?
    var url: String?
    var avatar: String?
    var repo: TrendingRepository?
    var type: TrendingUserType = .user
    
    init?(map: Map) {}
    
    init() {}
    
    mutating func mapping(map: Map) {
        username <- map["username"]
        name <- map["name"]
        url <- map["url"]
        avatar <- map["avatar"]
        repo <- map["repo"]
        type <- map["type"]
        repo?.author = username
    }
    
}

extension User {
    func getDetailCell() -> [DetailCellProperty] {
        var detailCellProperties: [DetailCellProperty] = []

        if let created = self.createdAt {
            detailCellProperties.append(DetailCellProperty(imgName: ImageName.icon_cell_created.rawValue, titleCell: "Created", detail: created.timeAgo(), hideDisclosure: true))
        }
        if let updated = self.updatedAt {
            detailCellProperties.append(DetailCellProperty(imgName: ImageName.icon_cell_updated.rawValue, titleCell: "Updated", detail: updated.timeAgo(), hideDisclosure: true))
        }

        detailCellProperties.append(DetailCellProperty(id: "starred", imgName: ImageName.icon_cell_star.rawValue, titleCell: "Stars", hideDisclosure: false))
        
        detailCellProperties.append(DetailCellProperty(id: "subscriptions", imgName: ImageName.icon_cell_theme.rawValue, titleCell: "Watching", hideDisclosure: false))

        detailCellProperties.append(DetailCellProperty(id: "events", imgName: ImageName.icon_cell_events.rawValue, titleCell: "Events", hideDisclosure: false))

        if let company = self.company {
            detailCellProperties.append(DetailCellProperty(imgName: ImageName.icon_cell_company.rawValue, titleCell: "Company", detail: company, hideDisclosure: false))
        }
        
        if let blog = self.blog {
            detailCellProperties.append(DetailCellProperty(imgName: ImageName.icon_cell_link.rawValue, titleCell: "Blog", detail: blog, hideDisclosure: false))
        }
        
        return detailCellProperties
    }
}
