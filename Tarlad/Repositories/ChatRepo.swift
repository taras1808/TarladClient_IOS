//
//  ChatRepo.swift
//  Tarlad
//
//  Created by Taras Kulyavets on 24.09.2020.
//  Copyright © 2020 Tarlad. All rights reserved.
//

import RxSwift


protocol ChatRepo {
    
    func getChat(id: Int64) -> Observable<Chat>
    
    func getChatList(id: Int64) -> Observable<Set<User>>
}
