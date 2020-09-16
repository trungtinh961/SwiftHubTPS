//
//  WebviewViewController.swift
//  SwifthubTPS
//
//  Created by TPS on 9/8/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import UIKit
import WebKit
import Toast_Swift

class WebviewViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var webview: WKWebView!
    
    // MARK: - Private properties
    private var accessToken = ""   
    private let defaultSession = URLSession(configuration: .default)
    private var dataTask: URLSessionDataTask?
    
    // MARK: - Lifecycles
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let authURL = String(format: "%@?client_id=%@&scope=%@&redirect_uri=%@", arguments: [GITHUB.GITHUB_AUTHURL,GITHUB.GITHUB_CLIENT_ID,GITHUB.GITHUB_SCOPE,GITHUB.GITHUB_REDIRECT_URI])
       
        let urlRequest = URLRequest(url: URL(string: authURL)!)
        debugPrint(urlRequest)
        webview.navigationDelegate = self
        webview.load(urlRequest)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
        
    //MARK: - IBActions
    @IBAction func btnBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - WKNavigationDelegate
extension WebviewViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.view.makeToastActivity(.center)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {        
        self.view.hideAllToasts(includeActivity: true, clearQueue: true)
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        debugPrint(webView.url ?? "no url")
        let requestURLString = (webView.url?.absoluteString)! as String
        if requestURLString.hasPrefix(GITHUB.GITHUB_REDIRECT_URI) {
            if let range: Range<String.Index> = requestURLString.range(of: "?code=") {
                handleGithubCode(code: String(requestURLString[range.upperBound...]))
            }
        }
    }
   
    func handleGithubCode(code: String) {
        let params = [
            "client_id" : GITHUB.GITHUB_CLIENT_ID,
            "client_secret" : GITHUB.GITHUB_CLIENT_SECRET,
            "code" : code
        ]
        var components = URLComponents(string: "https://github.com/login/oauth/access_token")
        components?.setQueryItems(with: params)
        guard let url =  components?.url else { return }
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        guard let urlRequest = request.url else { return }
        let queue = DispatchQueue.global()
        queue.async {
            guard let data = try? Data(contentsOf: urlRequest) else { return }
            let content = String(decoding: data, as: UTF8.self).removingPercentEncoding!.split(separator: "&")
            let seperator = content[0].firstIndex(of: "=")!
            let status = String(content[0][...content[0].index(before: seperator)])
            if status == "access_token" {
                self.accessToken = String(content[0][content[0].index(after: seperator)...])
                debugPrint("Access token: \(self.accessToken)")
            } else {
                debugPrint("Login failed!")
            }
            DispatchQueue.main.async {
                if status == "access_token" {
                    let mainTabBarController = self.storyboard?.instantiateViewController(withIdentifier: StoryboardIdentifier.tabbar.rawValue) as? MainTabBarController
                    mainTabBarController?.gitHubAuthenticationManager.didAuthenticated = true
                    mainTabBarController?.gitHubAuthenticationManager.accessToken = self.accessToken
                    mainTabBarController?.modalTransitionStyle = .flipHorizontal
                    mainTabBarController?.modalTransitionStyle = .flipHorizontal
                    self.view.window?.rootViewController = mainTabBarController
                    self.view.window?.makeKeyAndVisible()
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }   
}
