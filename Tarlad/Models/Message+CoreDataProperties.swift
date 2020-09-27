//
//  Message+CoreDataProperties.swift
//  
//
//  Created by Taras Kulyavets on 27.09.2020.
//
//

import Foundation
import CoreData


extension Message {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message")
    }

    @NSManaged public var chatId: Int64
    @NSManaged public var data: String?
    @NSManaged public var id: Int64
    @NSManaged public var time: Int64
    @NSManaged public var type: String?
    @NSManaged public var userId: Int64

}
