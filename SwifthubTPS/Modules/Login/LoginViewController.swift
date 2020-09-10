//
//  SecondViewController.swift
//  SwifthubTPS
//
//  Created by TPS on 8/24/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import UIKit

enum LoginType {
    case oauth
    case personal
    case basic
}

class LoginViewController: UIViewController {
    
    // MARK: - Properties
    
    private var loginType: LoginType = .oauth
    
    @IBOutlet weak var btnOauth: UIButton!
    @IBOutlet weak var oauthView: UIView!
    
    
    // MARK: - Life Cycles
      
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnOauth.layer.cornerRadius = 5
        
    }
    
    // MARK: - IBActions

    @IBAction func btnOauth(_ sender: Any) {
        showAlertWithDistructiveButton()
    }
    
    private func showAlertWithDistructiveButton() {
        let alert = UIAlertController(title: "\"SwiftHub\" wants to use \"github.com\" to sign in.", message: "This allows the app and website to share information about you.", preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { _ in
            //Cancel Action
        }))
        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: {(_: UIAlertAction!) in
            self.login()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Public Methods
    
    func login() {
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let webviewViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.webviewVC.rawValue) as! WebviewViewController
        webviewViewController.modalPresentationStyle = .automatic
        webviewViewController.modalTransitionStyle = .flipHorizontal
        present(webviewViewController, animated:true, completion:nil)
    }
   
}

extension LoginViewController: UIWebViewDelegate {
    
}

