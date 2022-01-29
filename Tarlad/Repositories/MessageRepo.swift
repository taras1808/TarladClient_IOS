//
//  MessageRepo.swift
//  Tarlad
//
//  Created by Taras Kulyavets on 05.10.2020.
//  Copyright © 2020 Tarlad. All rights reserved.
//

import RxSwift


protocol MessageRepo {
    
    var time: Int { get set }
    
    func getMessage(chatId: Int) -> Observable<Set<Message>>
    
    func observeMessages(chatId: Int) -> Observable<Set<Message>>
    
}
