//
//  MessageRepoImpl.swift
//  Tarlad
//
//  Created by Taras Kulyavets on 25.09.2020.
//  Copyright © 2020 Tarlad. All rights reserved.
//

import RxSwift
import SocketIO
import CoreData
import Foundation
import UIKit

public class MessageRepoImpl: MessageRepo {
    
    public static let shared = MessageRepoImpl()
    
    public var addMessageListener: UUID? = nil
    public var updateMessageListener: UUID? = nil
    public var deleteMessageListener: UUID? = nil
    
    let managedContext: NSManagedObjectContext
    
    init() {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        managedContext = appDelegate.persistentContainer.viewContext
    }
    
    func getMessage(page: Int64, time: Int64) -> Observable<[Message]> {
        
        return Observable.create { emitter in
            var cache: [Message] = []
            
            do {
                let fetchRequest: NSFetchRequest<Message> = NSFetchRequest(entityName: "Message")
                fetchRequest.fetchLimit = 10
                fetchRequest.fetchOffset = Int(10 * page)
                fetchRequest.predicate = NSPredicate(format: "time < \(time)")
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "time", ascending: false)]
                cache = try self.managedContext.fetch(fetchRequest)
                if !cache.isEmpty {
                    emitter.onNext(cache)
                }
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            if SocketIO.shared.socket.status == .connected {
                self.fetchMessages(cache: cache, time: time, page: page, emitter: emitter)
            } else {
                SocketIO.shared.socket.once(clientEvent: .connect) { _, _ in
                    self.fetchMessages(cache: cache, time: time, page: page, emitter: emitter)
                }
            }
            
            return Disposables.create()
        }
    }
    
    func fetchMessages(cache: [Message],time: Int64, page: Int64, emitter: AnyObserver<[Message]>) {
        SocketIO.shared.socket.emitWithAck("chats/messages/last", with: [time, page])
            .timingOut(after: 0) { items in
                if items.count == 0 { return }
                if items[0] is String {
                    print(items)
                    return
                }
                    
                var messages: [Message] = []

//                for item in items[0] as! [[String: Any]] {
//                    let message = Message()
//                    messages.append(message)
//                }
                
                if !messages.isEmpty && !messages.elementsEqual(cache) {
                    
//                    for message in messages {
//                        let messageEntity = NSEntityDescription.insertNewObject(forEntityName: "Message", into: self.managedContext)
//                        message.setEntity(obj: messageEntity)
//                    }
                    
                    do {
                        try self.managedContext.save()
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    }
                
                    emitter.onNext(messages)
                }
                emitter.onCompleted()
            }
    }
    
    func observeMessages() -> Observable<[Message]> {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        return Observable.create { emitter -> Disposable in
            
            if let uuid = self.addMessageListener {
                SocketIO.shared.socket.off(id: uuid)
            }
            self.addMessageListener = SocketIO.shared.socket.on("messages") { items, _ in
                
//                let item = items[0] as! [String: Any]
//
//                let message = Message(item: item)
//                let messageEntity = NSEntityDescription.insertNewObject(forEntityName: "Message", into: self.managedContext)
//                message.setEntity(obj: messageEntity)
//
//                do {
//                    try managedContext.save()
//                } catch let error as NSError {
//                    print("Could not save. \(error), \(error.userInfo)")
//                }
                
//                emitter.onNext([message])
            }
            
            if let uuid = self.updateMessageListener {
                SocketIO.shared.socket.off(id: uuid)
            }
            self.updateMessageListener = SocketIO.shared.socket.on("messages/update") { items, _ in
                let item = items[0] as! [String: Any]
                
                // TODO DELETE
//                let message = Message(item: item)
//                let messageEntity = NSEntityDescription.insertNewObject(forEntityName: "Message", into: self.managedContext)
//                message.setEntity(obj: messageEntity)
//
//                do {
//                    try managedContext.save()
//                } catch let error as NSError {
//                    print("Could not save. \(error), \(error.userInfo)")
//                }
                
//                emitter.onNext([messsage])
            }
            
            if let uuid = self.deleteMessageListener {
                SocketIO.shared.socket.off(id: uuid)
            }
            self.deleteMessageListener = SocketIO.shared.socket.on("messages/delete") { items, _ in
                //let item = items[0] as! Int64
                //self.fetchLastMessageForChat(chatId: item, emitter: emitter)
            }
            
            return Disposables.create()
        }
    }
    
    func fetchLastMessageForChat(chatId: Int64, emitter: AnyObserver<[Message]>) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        SocketIO.shared.socket.emitWithAck("messages/last", with: [chatId]).timingOut(after: 0) { items in
            if items.isEmpty {
                return
            }
            
            let item = items[0] as! [String: Any]
            
//            let message = Message(item: item)
//
//            do {
//                try managedContext.save()
//            } catch let error as NSError {
//                print("Could not save. \(error), \(error.userInfo)")
//            }
//
//            emitter.onNext([message])
        }
    }
}
