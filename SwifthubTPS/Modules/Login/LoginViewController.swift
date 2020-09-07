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
        
    }
    
    // MARK: - IBActions

    @IBAction func btnOauth(_ sender: Any) {
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

