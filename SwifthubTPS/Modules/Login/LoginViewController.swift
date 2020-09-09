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
    @IBOutlet weak var btnPersonal: UIButton!
    @IBOutlet weak var btnBasic: UIButton!
    @IBOutlet weak var oauthView: UIView!
    @IBOutlet weak var personalView: UIView!
    @IBOutlet weak var basicView: UIView!
    @IBOutlet weak var txtToken: UITextField!
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPasswork: UITextField!
    @IBOutlet weak var loginSegmentControl: UISegmentedControl!

    
    // MARK: - Life Cycles
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillShowing()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnOauth.layer.cornerRadius = 5
        btnPersonal.layer.cornerRadius = 5
        btnBasic.layer.cornerRadius = 5
        
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
        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.destructive, handler: {(_: UIAlertAction!) in
                let storyBoard = UIStoryboard(name: "Main", bundle:nil)
                let webviewViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.webviewVC.rawValue) as! WebviewViewController
                webviewViewController.modalPresentationStyle = .automatic
                webviewViewController.modalTransitionStyle = .flipHorizontal
                self.present(webviewViewController, animated:true, completion:nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnPersonal(_ sender: Any) {
    }
    
    @IBAction func btnBasic(_ sender: Any) {
    }
    
    @IBAction func loginSegmentControl(_ sender: Any) {
        switch loginSegmentControl.selectedSegmentIndex {
        case 0: loginType = .oauth
        case 1: loginType = .personal
        case 2: loginType = .basic
        default: loginType = .oauth
        }
        viewWillShowing()
    }
    
    
    // MARK: - Private Methods
    
    private func viewWillShowing() {
        if loginType == .oauth {
            oauthView.isHidden = false
            personalView.isHidden = true
            basicView.isHidden = true
        } else if loginType == .personal {
            oauthView.isHidden = true
            personalView.isHidden = false
            basicView.isHidden = true
        } else {
            oauthView.isHidden = true
            personalView.isHidden = true
            basicView.isHidden = false
        }
    }
}

extension LoginViewController: UIWebViewDelegate {
    
}

