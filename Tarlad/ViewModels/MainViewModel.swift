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
    
    let messages = Box<[Message]>([])
    let user = Box<User?>(nil)
    let chat = Box<Chat?>(nil)
    let chatList = Box<[Int64: Set<User>]?>(nil)
    
    var isLoading = false
    
    
    var time = Int64(Date().timeIntervalSince1970 * 1000)
    var page: Int64 = 0
    
    let userRepo: UserRepo = UserRepoImpl.shared
    let chatRepo: ChatRepo = ChatRepoImpl.shared
    let messageRepo: MessageRepo = MessageRepoImpl.shared
    
    func getMessages() -> Disposable {
        return messageRepo.getMessage(page: page, time: time)
            .do(onCompleted: {
                self.isLoading = false
            }, onSubscribe: {
                self.isLoading = true
                self.page += 1
            })
            .subscribe(onNext: { result in
                self.messages.value = result
            })
    }
    
    func observeMessages() -> Disposable {
        return messageRepo.observeMessages()
            .subscribe(onNext: { result in
                self.messages.value = result
            })
    }
    
    func getUser(id: Int64) -> Disposable {
        return userRepo.getUser(id: id)
            .subscribe(onNext: { result in
                self.user.value = result
            })
    }
    
    func getChat(id: Int64) -> Disposable {
        return chatRepo.getChat(id: id)
            .subscribe(onNext: { result in
                self.chat.value = result
            })
    }
    
    func getChatList(id: Int64) -> Disposable {
        return chatRepo.getChatList(id: id)
            .subscribe(onNext: { result in
                self.chatList.value = [id: result]
            })
    }
    
    
}
