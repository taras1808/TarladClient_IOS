//
//  MessageRepo.swift
//  Tarlad
//
//  Created by Taras Kulyavets on 05.10.2020.
//  Copyright © 2020 Tarlad. All rights reserved.
//

import RxSwift


protocol MessageRepo {
    
    var time: Int64 { get set }
    
    func getMessage(chatId: Int64) -> Observable<Set<Message>>
    
    func observeMessages(chatId: Int64) -> Observable<Set<Message>>
    
}
