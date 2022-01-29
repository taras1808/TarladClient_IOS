//
//  MainViewModel.swift
//  Tarlad
//
//  Created by Taras Kulyavets on 20.09.2020.
//  Copyright © 2020 Tarlad. All rights reserved.
//

import Foundation
import RxSwift

class MainViewModel {
    
    let messages = Box<Set<Message>>([])
    let user = Box<User?>(nil)
    let chat = Box<Chat?>(nil)
    let chatList = Box<[Int: Set<User>]?>(nil)
    
    var isLoading = false
    
    
    var time = Int(Date().timeIntervalSince1970 * 1000)
    var page: Int = 0
    
    let userRepo: UserRepo = UserRepoImpl.shared
    let chatRepo: ChatRepo = ChatRepoImpl.shared
    let mainRepo: MainRepo = MainRepoImpl.shared
    
    func getMessages() -> Disposable {
        return mainRepo.getMessage(page: page, time: time)
            .do(onSubscribe: {
                self.isLoading = true
                self.page += 1
            })
            .subscribe(onNext: { result in
                self.isLoading = false
                self.messages.value = result
            })
    }
    
    func observeMessages() -> Disposable {
        return mainRepo.observeMessages()
            .subscribe(onNext: { result in
                self.messages.value = result
            })
    }
    
    func getUser(id: Int) -> Disposable {
        return userRepo.getUser(id: id)
            .subscribe(onNext: { result in
                self.user.value = result
            })
    }
    
    func getChat(id: Int) -> Disposable {
        return chatRepo.getChat(id: id)
            .subscribe(onNext: { result in
                self.chat.value = result
            })
    }
    
    func getChatList(id: Int) -> Disposable {
        return chatRepo.getChatList(id: id)
            .subscribe(onNext: { result in
                self.chatList.value = [id: result]
            })
    }
    
    
}
