//
//  User.swift
//  Tarlad
//
//  Created by Taras Kulyavets on 20.09.2020.
//  Copyright © 2020 Tarlad. All rights reserved.
//

import Foundation
import CoreData


public class User: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }
    
    @NSManaged public var id: Int64
    @NSManaged public var nickname: String
    @NSManaged public var name: String
    @NSManaged public var surname: String
    @NSManaged public var imageURL: String?
    
    public func setData(item: [String: Any]) {
        id = item["id"] as! Int64
        nickname = item["nickname"] as! String
        name = item["name"] as! String
        surname = item["surname"] as! String
        imageURL = item["imageURL"] as? String
    }
    
    public class func getId(item: [String: Any]) -> Int64 {
        return item["id"] as! Int64
    }
}
