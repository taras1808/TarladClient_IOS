//
//  ChatViewController.swift
//  Tarlad
//
//  Created by Taras Kulyavets on 03.10.2020.
//  Copyright © 2020 Tarlad. All rights reserved.
//

import UIKit
import RxSwift


class ChatViewController: UIViewController {
    
    var chatId: Int64?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textView: UITextView!
    
    
    
    var messages: [Message] = []
    var users: [User] = []
    
    let disposeBag = DisposeBag()
    
    let vm = ChatViewModel()
    
    var y = CGFloat(0)
    
    lazy var inputContainerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100)
        
        containerView.backgroundColor = .yellow
        
        let textField = UITextField()
        textField.placeholder = "Message"
        containerView.addSubview(textField)
        textField.frame =  CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100)
        textField.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        
        return containerView
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
//    override var canBecomeFirstResponder: Bool {
//        return true
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        //tableView.transform = CGAffineTransform(rotationAngle: -.pi)
        //tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.size.width - 8)
        
        observeMessages()
        observeUsers()
        observeChats()
        
        
        vm.getMessages(chatId: chatId!).disposed(by: self.disposeBag)
    }
    
//    @IBOutlet weak var bottom: NSLayoutConstraint!
//    @objc func keyboardWillShow(notification: NSNotification) {
//        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//
//
//            UIView.animate(withDuration: 0.3, animations: {
//
////                self.bottom.constant = keyboardSize.height
//
//                self.tableView.contentInset = UIEdgeInsets(top: keyboardSize.height, left: 0.0, bottom: 0.0, right: 0.0)
//                self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: keyboardSize.height, left: 0.0, bottom: 0.0, right: 0.0)
////
//                self.view.frame.origin.y -= keyboardSize.height
//
//            })
//        }
//    }
//
//    @objc func keyboardWillHide(notification: NSNotification) {
//        //self.bottom.constant = 0
//    }

    func observeMessages() {
        vm.messages.bind(listener: { messages in
            if messages.count == 0 {
                self.tableView.reloadData()
                return
                
            }
            for message in messages {

                self.messages.removeAll { e in
                    e.id == message.id || e.managedObjectContext == nil
                }
                self.messages.append(message)
                self.messages.sort { o1, o2 in
                    return o1.time > o2.time
                }
            }
            
            for id in Set(messages.map({ e in e.userId })) {
                if !self.users.map({ e in e.id }).contains(id) {
                    self.vm.getUser(id: id).disposed(by: self.disposeBag)
                }
            }
            
            self.tableView.reloadData()
        })
    }
    
    func observeUsers() {
        vm.user.bind(listener: { user in
            guard let user = user else { return }
            self.users.append(user)
            self.tableView.reloadData()
        })
    }
    
    func observeChats() {
        vm.chat.bind(listener: { chat in
//            guard let chat = chat else { return }
//            self.chats.append(chat)
//            if !self.chatLists.keys.contains(chat.id) {
//                self.vm.getChatList(id: chat.id).disposed(by: self.disposeBag)
//            }
//            self.tableView.reloadData()
        })
    }
    

}

extension ChatViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: view.bounds.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        if estimatedSize.height > 200 { return }
        
        
        textView.constraints.forEach { const in
            if const.firstAttribute == .height {
                UIView.animate(withDuration: 0.3, animations: {
                    const.constant = estimatedSize.height
                })
            }
        }
        
    }
}


extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }

    func doLoad(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= messages.count - 1 && !vm.isLoading
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (doLoad(for: indexPath)) {
            vm.getMessages(chatId: chatId!).disposed(by: disposeBag)
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as? MessageCell  else {
            fatalError(".")
        }
        
        let item = self.messages[indexPath.row]
//        let id = UserDefaults.standard.integer(forKey: "USERID")
        
        let user = self.users.first { user in user.id == item.userId }
        
        cell.nickname.text = user?.nickname
        cell.message.text = "\(item.data)"
        
        //cell.transform = CGAffineTransform(rotationAngle: .pi);

        return cell
    }
}
