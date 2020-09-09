//
//  MainTabBarController.swift
//  SwifthubTPS
//
//  Created by TPS on 9/8/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import UIKit


class MainTabBarController: UITabBarController {

    // MARK: - Properties
    
    var gitHubAuthenticationManager = GITHUB()
    private let storyBoard = UIStoryboard(name: "Main", bundle:nil)
    private var userGithubAPI = GitHubAPI<User>()
    private var userItem: User?
    
    // MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.getAuthenUser()
        
        self.selectedIndex = 0
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    // MARK: - Private Methods
    
    private func getAuthenUser() {
        userGithubAPI.getResults(type: .getAuthenUser, gitHubAuthenticationManager: gitHubAuthenticationManager) { [weak self] results, errorMessage in
            if let result = results?[0] {
                self?.userItem = result                
                self?.viewControllers = self?.refreshAllTab(didAuthenticated: (self?.gitHubAuthenticationManager.didAuthenticated)!)
            }
            if !errorMessage.isEmpty {
                print("Search error: " + errorMessage)
            }
        }
    }
    
    
    
    private func refreshAllTab(didAuthenticated: Bool) -> [UIViewController] {
        var array: [UIViewController] = []
        
        ///Search VC
        let searchViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.searchVC.rawValue) as! SearchViewController
        let searchNavgitaionController = UINavigationController(rootViewController: searchViewController)
        searchNavgitaionController.title = "Search"
        searchNavgitaionController.tabBarItem.image = UIImage.init(named: ImageName.icon_tabbar_search.rawValue)
        
        
        
        if didAuthenticated {
            
            ///Event VC
            let eventViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.userEventVC.rawValue) as! UserEventViewController
            eventViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
            eventViewController.userItem = userItem
            let eventNavgitaionController = UINavigationController(rootViewController: eventViewController)
            eventNavgitaionController.isNavigationBarHidden = true
            eventNavgitaionController.title = "Event"
            eventNavgitaionController.tabBarItem.image = UIImage.init(named: ImageName.icon_tabbar_news.rawValue)
            
            ///Notification VC
            let activityViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.notificationVC.rawValue) as! NotificationViewController
            activityViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
            let activityNavgitaionController = UINavigationController(rootViewController: activityViewController)
            activityNavgitaionController.isNavigationBarHidden = true
            activityNavgitaionController.title = "Notifications"
            activityNavgitaionController.tabBarItem.image = UIImage.init(named: ImageName.icon_tabbar_activity.rawValue)
            
            ///Profile VC
            let userViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.userVC.rawValue) as! UserViewController
            userViewController.gitHubAuthenticationManager = gitHubAuthenticationManager
            userViewController.username = userItem?.login
            let userNavgitaionController = UINavigationController(rootViewController: userViewController)
            userNavgitaionController.isNavigationBarHidden = true
            userNavgitaionController.title = "Profile"
            userNavgitaionController.tabBarItem.image = UIImage.init(named: ImageName.icon_tabbar_profile.rawValue)
            
            array = [eventNavgitaionController, searchNavgitaionController, activityNavgitaionController, userNavgitaionController]
            
        } else {
            
            ///Login VC
            let loginViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.loginVC.rawValue) as! LoginViewController
            let loginNavgitaionController = UINavigationController(rootViewController: loginViewController)
            loginNavgitaionController.isNavigationBarHidden = true
            loginNavgitaionController.title = "Login"
            loginNavgitaionController.tabBarItem.image = UIImage.init(named: ImageName.icon_tabbar_login.rawValue)
            
            array = [searchNavgitaionController, loginNavgitaionController]
        }
        
        return array
    }

}
