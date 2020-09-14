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
    
    let currentUser = Sender(senderId: "self", displayName: "Steven")
    let otherUser = Sender(senderId: "other" , displayName: "John")
    var messages = [MessageType]()
    
    // MARK: - Private properties

    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messages.append(Message(sender: currentUser,
                                messageId: "1",
                                sentDate: Date().addingTimeInterval(-86400),
                                kind: .text("Hello")))
        messages.append(Message(sender: otherUser,
                                messageId: "2",
                                sentDate: Date().addingTimeInterval(-80000),
                                kind: .text("how are you")))
        messages.append(Message(sender: currentUser,
                                messageId: "3",
                                sentDate: Date().addingTimeInterval(-75000),
                                kind: .text("this is a good ideathis is a good ideathis is a good ideathis is a good ideathis is a good ideathis is a good ideathis is a good ideathis is a good ideathis is a good idea")))
        messages.append(Message(sender: otherUser,
                                messageId: "4",
                                sentDate: Date().addingTimeInterval(-60000),
                                kind: .text("make app easy")))
        messages.append(Message(sender: currentUser,
                                messageId: "5",
                                sentDate: Date().addingTimeInterval(-20000),
                                kind: .text("nguyennnnnnnnnnnnnnn trung tinhhhhhhhhhhhh")))
        
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
}

// MARK: - MessagesDataSource

extension ChatViewController: MessagesDataSource {

    func currentSender() -> SenderType {
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        return nil
    }
  
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }

    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
    
}


// MARK: - MessageCellDelegate
extension ChatViewController: MessageCellDelegate, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 18
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
}


// MARK: - InputBarAccessoryViewDelegate
extension ChatViewController: InputBarAccessoryViewDelegate {}
