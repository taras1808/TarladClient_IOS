////
////  Message.swift
////  Tarlad
////
////  Created by Taras Kulyavets on 20.09.2020.
////  Copyright © 2020 Tarlad. All rights reserved.
////

import Foundation
import CoreData


public class Message: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message")
    }

    @NSManaged public var chatId: Int64
    @NSManaged public var data: String
    @NSManaged public var id: Int64
    @NSManaged public var time: Int64
    @NSManaged public var type: String
    @NSManaged public var userId: Int64
    
    public func setData(item: [String: Any]) {
        id = item["id"] as! Int64
        userId = item["user_id"] as! Int64
        chatId = item["chat_id"] as! Int64
        type = item["type"] as! String
        data = item["data"] as! String
        time = item["time"] as! Int64
    }
    
    public class func getId(item: [String: Any]) -> Int64 {
        return item["id"] as! Int64
    }
}
