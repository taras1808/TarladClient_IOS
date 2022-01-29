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
    
    func getChat(id: Int) -> Observable<Chat> {
        return Observable.create { emitter in
            
            var cache: Chat? = nil
            
            do {
                let fetchRequest: NSFetchRequest<Chat> = Chat.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == \(id)")
                cache = try self.managedContext.fetch(fetchRequest).first
                if let chat = cache {
                    emitter.onNext(chat)
                }
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            if SocketIO.shared.socket.status == .connected {
                self.fetchChat(cache: cache, id: id, emitter: emitter)
            } else {
                SocketIO.shared.socket.once(clientEvent: .connect) { _, _ in
                    self.fetchChat(cache: cache, id: id, emitter: emitter)
                }
            }
            
            return Disposables.create()
        }
    }
    
    func fetchChat(cache: Chat?, id: Int, emitter: AnyObserver<Chat>) {
        SocketIO.shared.socket.emitWithAck("chats", id)
            .timingOut(after: 0) { items in
                if items.count == 0 { return }
                if items[0] is String {
                    return
                }
                let item = items[0] as! [String: Any]
                
                
                let chat = NSEntityDescription.insertNewObject(forEntityName: "Chat", into: self.managedContext) as! Chat
                chat.setData(item: item)

                if let cache = cache {
                    self.managedContext.delete(cache)
                }

                do {
                    try self.managedContext.save()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }

                emitter.onNext(chat)
            }
    }
    
    func getChatList(id: Int) -> Observable<Set<User>> {
        return Observable.create { emitter in
            
            var cache: Chat? = nil
            
            do {
                let fetchRequest: NSFetchRequest<Chat> = Chat.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == \(id)")
                cache = try self.managedContext.fetch(fetchRequest).first
                if let cache = cache, !(cache.users as! Set<User>).isEmpty {
                    emitter.onNext(cache.users as! Set<User>)
                }
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            if SocketIO.shared.socket.status == .connected {
                self.fetchChatList(cache: cache, id: id, emitter: emitter)
            } else {
                SocketIO.shared.socket.once(clientEvent: .connect) { _, _ in
                    self.fetchChatList(cache: cache, id: id, emitter: emitter)
                }
            }
            return Disposables.create()
        }
    }
    
    func fetchChatList(cache: Chat?, id: Int, emitter: AnyObserver<Set<User>>) {
        SocketIO.shared.socket.emitWithAck("chats/users", id)
            .timingOut(after: 0) { items in
                if items.count == 0 { return }
                if items[0] is String {
                    return
                }
                var users: Set<User> = []
                for item in items[0] as! [[String: Any]] {
                    let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: self.managedContext) as! User
                    user.setData(item: item)
                    users.insert(user)
                }
                
                if cache?.users as? Set<User> != users {
                    
                    
                    cache?.removeFromUsers(cache?.users ?? [])
                    cache?.addToUsers(users as NSSet)
                    
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
