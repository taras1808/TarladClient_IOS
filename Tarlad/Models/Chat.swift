//
//  Chat.swift
//  Tarlad
//
//  Created by Taras Kulyavets on 20.09.2020.
//  Copyright © 2020 Tarlad. All rights reserved.
//

import CoreData


struct Chat: Equatable {
    var id: Int64
    var title: String?
    var userId: Int64
    
    var users: Set<User> = []
    
    init(item: [String: Any]) {
        id = item["id"] as! Int64
        title = item["title"] as? String
        userId = item["user_id"] as! Int64
    }
    
    init(item: NSManagedObject) {
        id = item.value(forKey: "id") as! Int64
        title = item.value(forKey: "title") as? String
        userId = item.value(forKey: "userId") as! Int64
        for item in item.mutableSetValue(forKey: "users") as! Set<NSManagedObject> {
            self.users.insert(User(item: item))
        }
    }
    
    func setEntity(obj: NSManagedObject) {
        obj.setValue(id, forKey: "id")
        obj.setValue(title, forKey: "title")
        obj.setValue(userId, forKey: "userId")
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id &&
            lhs.title == rhs.title &&
            lhs.userId == rhs.userId
    }
}
