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


public class MainRepoImpl: MainRepo {
    
    public static let shared = MainRepoImpl()
    
    public var addMessageListener: UUID? = nil
    public var updateMessageListener: UUID? = nil
    public var deleteMessageListener: UUID? = nil
    
    let managedContext: NSManagedObjectContext
    
    init() {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        managedContext = appDelegate.persistentContainer.viewContext
    }
    
    func getMessage(page: Int, time: Int) -> Observable<Set<Message>> {
        
        return Observable.create { emitter in
            var cache: Set<Message> = []
            do {
                let groupRequest: NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
                let expressionId = NSExpression(forKeyPath: "id")
                let expression = NSExpression(forFunction: "max:", arguments: [expressionId])
                let maxId = NSExpressionDescription()
                maxId.expression = expression
                maxId.name = "maxId"
                maxId.expressionResultType = .integer64AttributeType
                
                groupRequest.fetchLimit = 10
                groupRequest.fetchOffset = Int(10 * page)
                groupRequest.propertiesToGroupBy = ["chatId"]
                groupRequest.propertiesToFetch = [maxId]
                groupRequest.predicate = NSPredicate(format: "time < \(time)")
                groupRequest.sortDescriptors = [NSSortDescriptor(key: "time", ascending: false)]
                groupRequest.resultType = .dictionaryResultType
                
                
                for item in try self.managedContext.fetch(groupRequest) as! [NSDictionary] {
                    let fetchRequest: NSFetchRequest<Message> = NSFetchRequest(entityName: "Message")
                    fetchRequest.predicate = NSPredicate(format: "id == \(item["maxId"]!)")
                    if let message = try self.managedContext.fetch(fetchRequest).first {
                        cache.insert(message)
                    }
                }
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
    
    func fetchMessages(cache: Set<Message>, time: Int, page: Int, emitter: AnyObserver<Set<Message>>) {
        SocketIO.shared.socket.emitWithAck("chats/messages/last", time, page)
            .timingOut(after: 0) { items in
                if items.count == 0 { return }
                if items[0] is String {
                    print(items)
                    return
                }
                    
                var messages: Set<Message> = []

                for item in items[0] as! [[String: Any]] {
                    let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: self.managedContext) as! Message
                    message.setData(item: item)
                    messages.insert(message)
                }
                
                cache.forEach { self.managedContext.delete($0) }
                
                do {
                    try self.managedContext.save()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
                
                if !messages.isEmpty {
                    emitter.onNext(messages)
                }
                
                emitter.onCompleted()
            }
    }
    
    func observeMessages() -> Observable<Set<Message>> {
        
        return Observable.create { emitter -> Disposable in
            
            if let uuid = self.addMessageListener {
                SocketIO.shared.socket.off(id: uuid)
            }
            self.addMessageListener = SocketIO.shared.socket.on("messages") { items, _ in
                let item = items[0] as! [String: Any]
                
                let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: self.managedContext) as! Message
                message.setData(item: item)

                do {
                    try self.managedContext.save()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
                
                emitter.onNext([message])
            }
            
            if let uuid = self.updateMessageListener {
                SocketIO.shared.socket.off(id: uuid)
            }
            self.updateMessageListener = SocketIO.shared.socket.on("messages/update") { items, _ in
                let item = items[0] as! [String: Any]

                let fetchRequest: NSFetchRequest<Message> = NSFetchRequest(entityName: "Message")
                fetchRequest.predicate = NSPredicate(format: "id == \(item["id"] as! Int64)")
                
                var message: Message?
                
                do {
                    
                    message = try self.managedContext.fetch(fetchRequest).first
                    
                    if message == nil {
                        message = (NSEntityDescription.insertNewObject(forEntityName: "Message", into: self.managedContext) as! Message)
                    }
                    
                    message!.setData(item: item)
                    
                    try self.managedContext.save()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
                
                emitter.onNext([message!])
            }
            
            if let uuid = self.deleteMessageListener {
                SocketIO.shared.socket.off(id: uuid)
            }
            self.deleteMessageListener = SocketIO.shared.socket.on("messages/delete") { items, _ in
                let item = items[0] as! Int
                
                
                let fetchRequest: NSFetchRequest<Message> = NSFetchRequest(entityName: "Message")
                fetchRequest.predicate = NSPredicate(format: "id == \(item)")
                
                do {
                    
                    let message = try self.managedContext.fetch(fetchRequest).first
                    
                    if let message = message {
                        self.managedContext.delete(message)
                    }
                    
                    
                    try self.managedContext.save()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
                
                self.fetchLastMessageForChat(chatId: item, emitter: emitter)
            }
            
            return Disposables.create()
        }
    }
    
    func fetchLastMessageForChat(chatId: Int, emitter: AnyObserver<Set<Message>>) {
        
        SocketIO.shared.socket.emitWithAck("messages/last", chatId).timingOut(after: 0) { items in
            if items.isEmpty {
                return
            }
            
            let item = items[0] as! [String: Any]
            
            let fetchRequest: NSFetchRequest<Message> = NSFetchRequest(entityName: "Message")
            fetchRequest.predicate = NSPredicate(format: "id == \(item["id"] as! Int64)")
            
            
            
            do {
                
                var message = try self.managedContext.fetch(fetchRequest).first
                
                if message == nil {
                    message = (NSEntityDescription.insertNewObject(forEntityName: "Message", into: self.managedContext) as! Message)
                }
                
                message!.setData(item: item)
                
                try self.managedContext.save()
                
                emitter.onNext([message!])
                
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
}
