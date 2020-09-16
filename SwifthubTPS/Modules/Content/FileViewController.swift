//
//  FileViewController.swift
//  SwifthubTPS
//
//  Created by TPS on 9/16/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import UIKit

class FileViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var txtContent: UITextView!
    
    // MARK: - Public properties
    var contentItem: Content?
    var repositoryItem: Repository?
    var gitHubAuthenticationManager = GITHUB()
    
    // MARK: - Private properties
    private var isLoading = false
    private let defaultSession = URLSession(configuration: .default)
    private var dataTask: URLSessionDataTask?
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getExtension()
        getContent()
    }    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - IBActions
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }    
    
    // MARK: - Private Methods
    private func getExtension() {
        let pathExtention = URL(fileURLWithPath: (contentItem!.name!)).pathExtension
        switch pathExtention {
        case "png", "jpg":
            showError()
        default:
            break
        }
    }
    
    private func showError() {
        let alert = UIAlertController(title: "Error", message: "The file \"\(contentItem?.name ?? "")\" couldn't be opened beacause the text encoding of its contents can't be determined.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func getContent() {
        let components = URLComponents(string: contentItem?.url ?? "")
        guard let url =  components?.url else { return }
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github.v3.raw", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
        dataTask = defaultSession.dataTask(with: request) { [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }
            if let error = error {
                print("DataTask error: " + error.localizedDescription)
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                    DispatchQueue.main.async {
                        self?.txtContent.text = String(data: data, encoding: .utf8)
                    }
            }
        }
        dataTask?.resume()
    }
}
