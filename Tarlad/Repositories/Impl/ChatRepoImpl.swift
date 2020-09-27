//
//  ChatRepoImpl.swift
//  Tarlad
//
//  Created by Taras Kulyavets on 24.09.2020.
//  Copyright © 2020 Tarlad. All rights reserved.
//

import RxSwift
import CoreData


class ChatRepoImpl: ChatRepo {
    
    public static let shared = ChatRepoImpl()
    
    let managedContext: NSManagedObjectContext
    
    init() {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        managedContext = appDelegate.persistentContainer.viewContext
    }
    
    func getChat(id: Int64) -> Observable<Chat> {
        return Observable.create { emitter in
            
            var cache: Chat? = nil
            var cacheNS: NSManagedObject? = nil
            
            do {
                let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Chat")
                fetchRequest.predicate = NSPredicate(format: "id == \(id)")
                let objects = try self.managedContext.fetch(fetchRequest)
                for item in objects {
                    let chat = Chat(item: item)
                    cache = chat
                    cacheNS = item
                }
                if let chat = cache {
                    emitter.onNext(chat)
                }
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            if SocketIO.shared.socket.status == .connected {
                self.fetchChat(cache: cache, cacheNS: cacheNS, id: id, emitter: emitter)
            } else {
                SocketIO.shared.socket.once(clientEvent: .connect) { _, _ in
                    self.fetchChat(cache: cache, cacheNS: cacheNS, id: id, emitter: emitter)
                }
            }
            
            return Disposables.create()
        }
    }
    
    func fetchChat(cache: Chat?, cacheNS: NSManagedObject?, id: Int64, emitter: AnyObserver<Chat>) {
        SocketIO.shared.socket.emitWithAck("chats", with: [id])
            .timingOut(after: 0) { items in
                if items.count == 0 { return }
                if items[0] is String {
                    return
                }
                let item = items[0] as! [String: Any]
                let chat = Chat(item: item)
                
                
                if chat != cache {
                
                    let chatEntity = NSEntityDescription.insertNewObject(forEntityName: "Chat", into: self.managedContext)
                    chat.setEntity(obj: chatEntity)
                    
                    if let cacheNS = cacheNS {
                        self.managedContext.delete(cacheNS)
                    }
                    
                    do {
                        try self.managedContext.save()
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    }
                
                    emitter.onNext(chat)
                }
            }
    }
    
    func getChatList(id: Int64) -> Observable<Set<User>> {
        return Observable.create { emitter in
            
            var cache: Set<User> = []
            var cacheNS: NSManagedObject? = nil
            
            do {
                let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Chat")
                fetchRequest.predicate = NSPredicate(format: "id == \(id)")
                let objects = try self.managedContext.fetch(fetchRequest)
                for item in objects {
                    let chat = Chat(item: item)
                    cache = chat.users
                    cacheNS = item
                }
                if !cache.isEmpty {
                    emitter.onNext(cache)
                }
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            if SocketIO.shared.socket.status == .connected {
                self.fetchChatList(cache: cache, cacheNS: cacheNS, id: id, emitter: emitter)
            } else {
                SocketIO.shared.socket.once(clientEvent: .connect) { _, _ in
                    self.fetchChatList(cache: cache, cacheNS: cacheNS, id: id, emitter: emitter)
                }
            }
            return Disposables.create()
        }
    }
    
    func fetchChatList(cache: Set<User>, cacheNS: NSManagedObject?, id: Int64, emitter: AnyObserver<Set<User>>) {
        SocketIO.shared.socket.emitWithAck("chats/users", with: [id])
            .timingOut(after: 0) { items in
                if items.count == 0 { return }
                if items[0] is String {
                    return
                }
                var users: Set<User> = []
                var usersNS: Set<NSManagedObject> = []
                for item in items[0] as! [[String: Any]] {
                    let user = User(item: item)
                    // TODO DELETE
                    let userEntity = NSEntityDescription.insertNewObject(forEntityName: "User", into: self.managedContext)
                    user.setEntity(obj: userEntity)
                    users.insert(user)
                    usersNS.insert(userEntity)
                }
                
                if cache != users {
                    if let cacheNS = cacheNS {
                        cacheNS.setValue(usersNS, forKey: "users")
                    }
                    
                    do {
                        try self.managedContext.save()
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    }
                    
                    emitter.onNext(users)
                }
                emitter.onCompleted()
            }
    }
}
