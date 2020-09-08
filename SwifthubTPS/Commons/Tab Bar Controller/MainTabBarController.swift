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
    
    public var gitHubToken = GITHUB()
    let storyBoard = UIStoryboard(name: "Main", bundle:nil)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if gitHubToken.isAuthenticated == true {
            let eventViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.userEventVC.rawValue) as! UserEventViewController
            let eventNavgitaionController = UINavigationController(rootViewController: eventViewController)
            eventNavgitaionController.title = "Event"
            eventNavgitaionController.tabBarItem.image = UIImage.init(named: ImageName.icon_tabbar_news.rawValue)
            var array = self.viewControllers
            array?.insert(eventNavgitaionController, at: 0)
            self.viewControllers = array
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.selectedIndex = 0
        
    }
    
    
    

}
