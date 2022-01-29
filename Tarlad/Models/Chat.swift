//
//  Chat.swift
//  Tarlad
//
//  Created by Taras Kulyavets on 20.09.2020.
//  Copyright © 2020 Tarlad. All rights reserved.
//

import Foundation
import CoreData


public class Chat: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Chat> {
        return NSFetchRequest<Chat>(entityName: "Chat")
    }
    
    @NSManaged public var id: Int
    @NSManaged public var title: String?
    @NSManaged public var userId: Int
    
    @NSManaged public var users: NSSet
    
    public func setData(item: [String: Any]) {
        id = item["id"] as! Int
        title = item["title"] as? String
        userId = item["user_id"] as! Int
    }
    
    public class func getId(item: [String: Any]) -> Int {
        return item["id"] as! Int
    }
    
    @objc(addUsersObject:)
    @NSManaged public func addToUsers(_ value: User)

    @objc(removeUsersObject:)
    @NSManaged public func removeFromUsers(_ value: User)

    @objc(addUsers:)
    @NSManaged public func addToUsers(_ values: NSSet)

    @objc(removeUsers:)
    @NSManaged public func removeFromUsers(_ values: NSSet)
}
