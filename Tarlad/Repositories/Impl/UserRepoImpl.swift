//
//  UserRepoImpl.swift
//  Tarlad
//
//  Created by Taras Kulyavets on 24.09.2020.
//  Copyright © 2020 Tarlad. All rights reserved.
//

import RxSwift
import CoreData


class UserRepoImpl: UserRepo {
    
    public static let shared = UserRepoImpl()
    
    let managedContext: NSManagedObjectContext
    
    init() {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        managedContext = appDelegate.persistentContainer.viewContext
    }
    
    func getUser(id: Int64) -> Observable<User> {
        
        return Observable.create { emitter in
            
            var cache: User? = nil
            var cacheNS: NSManagedObject? = nil
            
            do {
                let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "User")
                fetchRequest.predicate = NSPredicate(format: "id == \(id)")
                let objects = try self.managedContext.fetch(fetchRequest)
                for item in objects {
                    let user = User(item: item)
                    cache = user
                    cacheNS = item
                }
                if let user = cache {
                    emitter.onNext(user)
                }
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        
            // TODO
            if SocketIO.shared.socket.status == .connected {
                self.fetchUser(cache: cache, cacheNS: cacheNS, id: id, emitter: emitter)
            } else {
                SocketIO.shared.socket.once(clientEvent: .connect) { _, _ in
                    self.fetchUser(cache: cache, cacheNS: cacheNS, id: id, emitter: emitter)
                }
            }
            
            return Disposables.create()
        }
    }
    
    func fetchUser(cache: User?, cacheNS: NSManagedObject?, id: Int64, emitter: AnyObserver<User>) {
        SocketIO.shared.socket.emitWithAck("users", with: [id])
            .timingOut(after: 0) { items in
                if items.count == 0 { return }
                if items[0] is String {
                    return
                }
                let item = items[0] as! [String: Any]
                let user = User(item: item)
                
                
                if user != cache {
                
                    let userEntity = NSEntityDescription.insertNewObject(forEntityName: "User", into: self.managedContext)
                    user.setEntity(obj: userEntity)
                    
                    
                    if let cacheNS = cacheNS {
                        self.managedContext.delete(cacheNS)
                    }
                    
                    do {
                        try self.managedContext.save()
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    }
                
                    emitter.onNext(user)
                }
            }
    }

}
