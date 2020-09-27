//
//  User.swift
//  Tarlad
//
//  Created by Taras Kulyavets on 20.09.2020.
//  Copyright © 2020 Tarlad. All rights reserved.
//

import CoreData


struct User: Equatable, Hashable {
    var id: Int64
    var nickname: String
    var name: String
    var surname: String
    var imageURL: String?
    
    init(item: [String: Any]) {
        id = item["id"] as! Int64
        nickname = item["nickname"] as! String
        name = item["name"] as! String
        surname = item["surname"] as! String
        imageURL = item["image_url"] as? String
    }
    
    init(item: NSManagedObject) {
        id = item.value(forKey: "id") as! Int64
        nickname = item.value(forKey: "nickname") as! String
        name = item.value(forKey: "name") as! String
        surname = item.value(forKey: "surname") as! String
        imageURL = item.value(forKey: "imageURL") as? String
    }
    
    func setEntity(obj: NSManagedObject) {
        obj.setValue(id, forKey: "id")
        obj.setValue(nickname, forKey: "nickname")
        obj.setValue(name, forKey: "name")
        obj.setValue(surname, forKey: "surname")
        obj.setValue(imageURL, forKey: "imageURL")
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id &&
            lhs.nickname == rhs.nickname &&
            lhs.name == rhs.name &&
            lhs.surname == rhs.surname &&
            lhs.imageURL == rhs.imageURL
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(nickname)
        hasher.combine(name)
        hasher.combine(surname)
        hasher.combine(imageURL)
    }
}
