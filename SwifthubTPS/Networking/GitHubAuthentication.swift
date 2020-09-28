//
//  GitHubAuthentication.swift
//  SwifthubTPS
//
//  Created by TPS on 9/8/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import Foundation


struct GITHUB {
    static var GITHUB_AUTHURL = "https://github.com/login/oauth/authorize"
    static var GITHUB_ACCESSURL = "https://github.com/login/oauth/access_token"
    static var GITHUB_REDIRECT_URI = "https://localhost:4567/callback"
    static var GITHUB_CLIENT_ID = "ad4041734cb989d5a24f"
    static var GITHUB_CLIENT_SECRET = "ceccf1dca688d25c057b497058fb731ec6837c93"
    static var GITHUB_SCOPE = "user+repo+notifications+read:org"
    
    var accessToken: String?
    var didAuthorizated: Bool = false
    var userAuthorizated: User?
}
