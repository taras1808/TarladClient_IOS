//
//  MessageRepo.swift
//  Tarlad
//
//  Created by Taras Kulyavets on 25.09.2020.
//  Copyright © 2020 Tarlad. All rights reserved.
//

import RxSwift


protocol MessageRepo {
    
    func getMessage(page: Int64, time: Int64) -> Observable<[Message]>
    
    func observeMessages() -> Observable<[Message]>
    
}
