//
//  ChatViewModel.swift
//  Tarlad
//
//  Created by Taras Kulyavets on 05.10.2020.
//  Copyright © 2020 Tarlad. All rights reserved.
//

import Foundation
import RxSwift

class ChatViewModel {
    
    let messages = Box<Set<Message>>([])
    let user = Box<User?>(nil)
    let chat = Box<Chat?>(nil)
    
    init() {
        messageRepo.time = Int.max
    }
    
    var isLoading = false
    
    let userRepo: UserRepo = UserRepoImpl.shared
    let chatRepo: ChatRepo = ChatRepoImpl.shared
    var messageRepo: MessageRepo = MessageRepoImpl.shared
    
    func getMessages(chatId: Int) -> Disposable {
        return messageRepo.getMessage(chatId: chatId)
            .do(onSubscribe: {
                self.isLoading = true
            })
            .subscribe(onNext: { result in
                self.isLoading = false
                self.messages.value = result
            })
    }
    
    func observeMessages(chatId: Int) -> Disposable {
        return messageRepo.observeMessages(chatId: chatId)
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
}
