//
//  WebviewViewController.swift
//  SwifthubTPS
//
//  Created by TPS on 9/8/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import UIKit
import WebKit


class WebviewViewController: UIViewController {

    // MARK: - Properties
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    
    @IBOutlet weak var webview: WKWebView!
    
    
    // MARK: - Life Cycles
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let authURL = String(format: "%@?client_id=%@&scope=%@", arguments: [GITHUB.GITHUB_AUTHURL.rawValue,GITHUB.GITHUB_CLIENT_ID.rawValue,GITHUB.GITHUB_SCOPE.rawValue])

        let urlRequest = URLRequest(url: URL(string: authURL)!)
        print(urlRequest)
        webview.load(urlRequest)
        webview.navigationDelegate = self
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
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print(webView.url ?? "no url")
        let requestURLString = (webView.url?.absoluteString)! as String
        if requestURLString.hasPrefix(GITHUB.GITHUB_REDIRECT_URI.rawValue) {
            if let range: Range<String.Index> = requestURLString.range(of: "?code=") {
                handleGithubCode(code: String(requestURLString[range.upperBound...]))
            }
        }
    }
    
    func checkRequestForCallbackURL(request: URLRequest) -> Void {
        let requestURLString = (request.url?.absoluteString)! as String
        if requestURLString.hasPrefix(GITHUB.GITHUB_REDIRECT_URI.rawValue) {
            if let range: Range<String.Index> = requestURLString.range(of: "?code=") {
                handleGithubCode(code: String(requestURLString[range.upperBound...]))
            }
        }
    }
    
    func handleGithubCode(code: String) {
        let params = [
            "client_id" : GITHUB.GITHUB_CLIENT_ID.rawValue,
            "client_secret" : GITHUB.GITHUB_CLIENT_SECRET.rawValue,
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
            let data = try? Data(contentsOf: urlRequest)
            let content = String(decoding: data!, as: UTF8.self).removingPercentEncoding!.split(separator: "&")
            let seperator = content[0].firstIndex(of: "=")!
            let status = String(content[0][...content[0].index(before: seperator)])
            if status == "access_token" {
                let accessToken = String(content[0][content[0].index(after: seperator)...])
                print("Access token: \(accessToken)")
            } else {
                print("Login failed!")
            }
            DispatchQueue.main.async {
                if status == "access_token" {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }

    }

   
}
