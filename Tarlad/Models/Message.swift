////
////  Message.swift
////  Tarlad
////
////  Created by Taras Kulyavets on 20.09.2020.
////  Copyright © 2020 Tarlad. All rights reserved.
////
//
import Foundation
import CoreData

extension Message {
    
    convenience init(item: [String: Any]) {
        self.init()
        id = item["id"] as! Int64
        userId = item["user_id"] as! Int64
        chatId = item["chat_id"] as! Int64
        type = item["type"] as? String
        data = item["data"] as? String
        time = item["time"] as! Int64
    }
}
