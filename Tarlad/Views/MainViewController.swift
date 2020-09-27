//
//  MainViewController.swift
//  Tarlad
//
//  Created by Taras Kulyavets on 19.09.2020.
//  Copyright © 2020 Tarlad. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift


class MainViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var chats: [Chat] = []
    var messages: [Message] = []
    var users: [User] = []
    var chatLists: [Int64: Set<User>] = [:]
    
    let disposeBag = DisposeBag()
    
    let vm = MainViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Tarlad"
        
        tableView.delegate = self
        tableView.dataSource = self
        
        observeMessages()
        observeUsers()
        observeChats()
        observeChatList()
        
        vm.observeMessages().disposed(by: disposeBag)
        
        vm.getMessages().disposed(by: self.disposeBag)
    }
    
    @IBAction func unwindToMain(unwindSegue: UIStoryboardSegue) {
        self.vm.page = 0
        self.vm.time = Int64(Date().timeIntervalSince1970 * 1000)
        self.chats = []
        self.messages = []
        self.users = []
        self.chatLists = [:]
        self.tableView.reloadData()
        self.vm.getMessages().disposed(by: self.disposeBag)
    }
    
    func observeMessages() {
        vm.messages.bind(listener: { messages in
            if messages.count == 0 { return }
            for message in messages {

                if !self.chats.map({ e in e.id }).contains(message.chatId) {
                    self.vm.getChat(id: message.chatId).disposed(by: self.disposeBag)
                } else {
                    if !self.users.map({ e in e.id }).contains(message.userId) {
                        self.vm.getUser(id: message.userId).disposed(by: self.disposeBag)
                    }
                }
                
                self.messages.removeAll { e in
                    e.id == message.id || e.chatId == message.chatId
                }
                self.messages.append(message)
                self.messages.sort { o1, o2 in
                    return o1.time > o2.time
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
            guard let chat = chat else { return }
            self.chats.append(chat)
            if !self.chatLists.keys.contains(chat.id) {
                self.vm.getChatList(id: chat.id).disposed(by: self.disposeBag)
            }
            self.tableView.reloadData()
        })
    }
    
    func observeChatList() {
        vm.chatList.bind(listener: { dictionary in
            guard let dictionary = dictionary else { return }
            self.chatLists[dictionary.keys.first!] = dictionary.values.first!
            self.users.removeAll { user in dictionary.values.first!.contains(user)}
            self.users.append(contentsOf: dictionary.values.first!)
            self.tableView.reloadData()
        })
    }
}


extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    
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
            vm.getMessages().disposed(by: disposeBag)
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as? ChatCell  else {
            fatalError(".")
        }
        
        let item = self.messages[indexPath.row]
        let id = UserDefaults.standard.integer(forKey: "USERID")
        let users = self.chatLists[item.chatId]?.filter({ user -> Bool in user.id != id }) ?? []
        
        cell.title.text = self.chats
            .first(where: { (chat: Chat) -> Bool in
                chat.id == item.chatId
            })?.title ?? users.map({ user in user.nickname })
                .joined(separator: ", ")
        
        let user = users.first { user -> Bool in user.id == item.userId }
        let from = (user == nil) ? "you" : "\(user!.name) \(user!.surname)"
        let message = item.type != "media" ? item.data : "Send a photo"
        cell.message.text = "\(from): \(message)"
        
        return cell
    }
}
