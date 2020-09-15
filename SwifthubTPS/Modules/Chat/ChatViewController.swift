//
//  ChatViewController.swift
//  SwifthubTPS
//
//  Created by TPS on 9/11/20.
//  Copyright © 2020 Trung Tinh. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import SwiftDate
import Toast_Swift

class ChatViewController: MessagesViewController {
    
    // MARK: - Public properties
    var gitHubAuthenticationManager = GITHUB()
    var currentUser: User?
    var issueItem: Issue?
    var pullItem: PullRequest?
    var number: Int?
    var repoItem: Repository?
    var messages: [MessageType] = [] {
        didSet {
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToBottom(animated: true)
        }
    }
    
    // MARK: - Private properties
    private var downloadTask: URLSessionDownloadTask?
    private var issueCommentGithubAPI = GitHubAPI<Comment>()
    private var issueCommentItems: [Comment]?
    
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = repoItem?.fullname
        number = issueItem?.number ?? pullItem?.number ?? 0
        updateTableView(type: .getIssueComments)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentUser = gitHubAuthenticationManager.userAuthenticated
        configureMessageCollectionView()
        configureMessageInputBar()
    }
    
    func configureMessageCollectionView() {
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        scrollsToBottomOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        showMessageTimestampOnSwipeLeft = true
    }
    
    func configureMessageInputBar() {
        messageInputBar.delegate = self
        messageInputBar.inputTextView.tintColor = .primaryColor
        messageInputBar.sendButton.setTitleColor(.primaryColor, for: .normal)
        messageInputBar.sendButton.setTitleColor(
            UIColor.primaryColor.withAlphaComponent(0.3),
            for: .highlighted
        )
    }
    
    // MARK: - Private Methods
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }    
    
    private func updateTableView(type: GetType, body: String = ""){
        issueCommentGithubAPI.getResults(type: type, gitHubAuthenticationManager: gitHubAuthenticationManager, fullname: repoItem?.fullname ?? "", number: number ?? 0, body: body) { [weak self] results, errorMessage, statusCode in
            if let results = results {
                if type == .getIssueComments {
                    self?.messages = results
                } else {
                    self?.messages.append(contentsOf: results)
                }
            }
            if let statusCode = statusCode {
                if statusCode == 201 {
                    print("Create successfully comment to issue #\(self?.number ?? 0)")
                }
            }
            if !errorMessage.isEmpty {
                print("Search error: " + errorMessage)
            }
        }
    }
    
    
    // MARK: - Helpers

    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else { return false }
        return (messages[indexPath.section].sender as? User) == (messages[indexPath.section - 1].sender as? User)
    }

    func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < messages.count else { return false }
        return (messages[indexPath.section].sender as? User) == (messages[indexPath.section + 1].sender as? User)
    }
    
}

// MARK: - MessagesDataSource

extension ChatViewController: MessagesDataSource {

    func currentSender() -> SenderType {
        return currentUser ?? User()
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }

    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = message.sentDate.toRelative()
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
}


// MARK: - MessageCellDelegate
extension ChatViewController: MessageCellDelegate, MessagesDisplayDelegate {
   
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if let user = message.sender as? User {
            avatarView.isHidden = isNextMessageSameSender(at: indexPath)
            if let smallURL = URL(string: user.avatarUrl ?? "") {
                downloadTask = avatarView.loadImage(url: smallURL)
            }
        }
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        switch detector {
        case .hashtag, .mention: return [.foregroundColor: UIColor.blue]
        default: return MessageLabel.defaultAttributes
        }
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .primaryColor : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }
    
}

// MARK: - MessagesLayoutDelegate
extension ChatViewController: MessagesLayoutDelegate {

    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 10
    }

    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }

    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }

    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 22
    }
}

// MARK: - InputBarAccessoryViewDelegate
extension ChatViewController: InputBarAccessoryViewDelegate {
    @objc
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        if gitHubAuthenticationManager.didAuthenticated {
            inputBar.inputTextView.text = ""
            updateTableView(type: .createIssueComment, body: text)
        } else {
            print("You must be logged in to post!")
        }
    }
}
