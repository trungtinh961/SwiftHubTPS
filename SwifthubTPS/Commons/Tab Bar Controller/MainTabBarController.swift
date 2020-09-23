//
//  MainTabBarController.swift
//  SwifthubTPS
//
//  Created by TPS on 9/8/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import UIKit


class MainTabBarController: UITabBarController {

    // MARK: - Public properties
    var gitHubAuthenticationManager = GITHUB()
    
    // MARK: - Private properties
    private let storyBoard = UIStoryboard(name: "Main", bundle:nil)
    private var userGithubAPI = GitHubAPI<User>()
    private var userItem: User?
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if gitHubAuthenticationManager.didAuthenticated {
            self.getAuthenUser()
        }
        self.selectedIndex = 0
    }
    
    
    // MARK: - Private Methods
    private func getAuthenUser() {
        userGithubAPI.getResults(type: .getAuthenUser, gitHubAuthenticationManager: gitHubAuthenticationManager) { [weak self] results, errorMessage, statusCode in
            if let result = results?[0] {
                self?.userItem = result
                self?.gitHubAuthenticationManager.userAuthenticated = result
                self?.viewControllers = self?.refreshAllTab(didAuthenticated: (self?.gitHubAuthenticationManager.didAuthenticated)!)
            }
            if !errorMessage.isEmpty {
                debugPrint("Get data error: " + errorMessage)
            }
        }
    }
    
    private func refreshAllTab(didAuthenticated: Bool) -> [UIViewController] {
        var array: [UIViewController] = []
        
        ///Search VC
        let searchViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.searchVC.rawValue) as! SearchViewController
        searchViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
        let searchNavgitaionController = UINavigationController(rootViewController: searchViewController)
        searchNavgitaionController.title = "Search"
        searchNavgitaionController.tabBarItem.image = UIImage.init(named: ImageName.icon_tabbar_search.rawValue)
        
        if didAuthenticated {
            
            ///Event VC
            let eventViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.userEventVC.rawValue) as! UserEventViewController
            eventViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
            eventViewController.userItem = userItem
            eventViewController.isTabbarCall = true
            let eventNavgitaionController = UINavigationController(rootViewController: eventViewController)
            eventNavgitaionController.title = "Event"
            eventNavgitaionController.tabBarItem.image = UIImage.init(named: ImageName.icon_tabbar_news.rawValue)
            
            ///Notification VC
            let activityViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.notificationVC.rawValue) as! NotificationViewController
            activityViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
            let activityNavgitaionController = UINavigationController(rootViewController: activityViewController)
            activityNavgitaionController.title = "Notifications"
            activityNavgitaionController.tabBarItem.image = UIImage.init(named: ImageName.icon_tabbar_activity.rawValue)
            
            ///Profile VC
            let userViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.userVC.rawValue) as! UserViewController
            userViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
            userViewController.userItem = userItem
            userViewController.isTabbarCall = true
            let userNavgitaionController = UINavigationController(rootViewController: userViewController)
            userNavgitaionController.title = "Profile"
            userNavgitaionController.tabBarItem.image = UIImage.init(named: ImageName.icon_tabbar_profile.rawValue)
            array = [eventNavgitaionController, searchNavgitaionController, activityNavgitaionController, userNavgitaionController]
            
        } else {
            
            ///Login VC
            let loginViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.loginVC.rawValue) as! LoginViewController
            let loginNavgitaionController = UINavigationController(rootViewController: loginViewController)
            loginNavgitaionController.title = "Login"
            loginNavgitaionController.tabBarItem.image = UIImage.init(named: ImageName.icon_tabbar_login.rawValue)
            array = [searchNavgitaionController, loginNavgitaionController]
        }
        return array
    }
}
