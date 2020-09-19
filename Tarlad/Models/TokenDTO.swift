//
//  TokenDTO.swift
//  Tarlad
//
//  Created by Taras Kulyavets on 15.09.2020.
//  Copyright © 2020 Tarlad. All rights reserved.
//


struct TokenDTO: Codable {
    let token: String
    let refreshToken: Token
}
