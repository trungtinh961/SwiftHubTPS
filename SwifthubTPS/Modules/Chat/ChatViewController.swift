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
import Kingfisher

struct Sender: SenderType {
    public let senderId: String
    public let displayName: String
}
 
struct Message: MessageType {
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
}

class ChatViewController: MessagesViewController {
    
    // MARK: - Public properties
    var gitHubAuthenticationManager = GITHUB()
    var currentUser: User?
    let otherUser = Sender(senderId: "other" , displayName: "John")
    var messages: [MessageType] = [] {
        didSet {
            self.messagesCollectionView.reloadData()
        }
    }
    
    // MARK: - Private properties
    
    
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentUser = gitHubAuthenticationManager.userAuthenticated
        
//        messages.append(Message(sender: currentUser,
//                                messageId: "1",
//                                sentDate: Date().addingTimeInterval(-86400),
//                                kind: .text("Hello")))
//        messages.append(Message(sender: otherUser,
//                                messageId: "2",
//                                sentDate: Date().addingTimeInterval(-80000),
//                                kind: .text("how are you")))
//        messages.append(Message(sender: currentUser,
//                                messageId: "3",
//                                sentDate: Date().addingTimeInterval(-75000),
//                                kind: .text("this is a good ideathis is a good ideathis is a good ideathis is a good ideathis is a good ideathis is a good ideathis is a good ideathis is a good ideathis is a good idea")))
//        messages.append(Message(sender: otherUser,
//                                messageId: "4",
//                                sentDate: Date().addingTimeInterval(-60000),
//                                kind: .text("make app easy")))
//        messages.append(Message(sender: currentUser,
//                                messageId: "5",
//                                sentDate: Date().addingTimeInterval(-20000),
//                                kind: .text("nguyennnnnnnnnnnnnnn trung tinhhhhhhhhhhhh")))
        
        configureMessageCollectionView()
        configureMessageInputBar()
    }
    
    func configureMessageCollectionView() {
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        scrollsToBottomOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        showMessageTimestampOnSwipeLeft = true // default false
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
           avatarView.kf.setImage(with: user.avatarUrl)
       }
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
extension ChatViewController: InputBarAccessoryViewDelegate {}
