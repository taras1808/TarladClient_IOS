//
//  UserRepo.swift
//  Tarlad
//
//  Created by Taras Kulyavets on 24.09.2020.
//  Copyright © 2020 Tarlad. All rights reserved.
//

import RxSwift


protocol UserRepo {
    
    func getUser(id: Int64) -> Observable<User>
}
