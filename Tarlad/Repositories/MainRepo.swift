//
//  MessageRepo.swift
//  Tarlad
//
//  Created by Taras Kulyavets on 25.09.2020.
//  Copyright © 2020 Tarlad. All rights reserved.
//

import RxSwift


protocol MainRepo {
    
    func getMessage(page: Int, time: Int) -> Observable<Set<Message>>
    
    func observeMessages() -> Observable<Set<Message>>
    
}
