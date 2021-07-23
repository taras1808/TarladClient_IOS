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
            
            do {
                let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == \(id)")
                cache = try self.managedContext.fetch(fetchRequest).first
            
                if let user = cache {
                    emitter.onNext(user)
                }
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            if SocketIO.shared.socket.status == .connected {
                self.fetchUser(cache: cache, id: id, emitter: emitter)
            } else {
                SocketIO.shared.socket.once(clientEvent: .connect) { _, _ in
                    self.fetchUser(cache: cache, id: id, emitter: emitter)
                }
            }
            
            return Disposables.create()
        }
    }
    
    func fetchUser(cache: User?, id: Int64, emitter: AnyObserver<User>) {
        SocketIO.shared.socket.emitWithAck("users", with: [id])
            .timingOut(after: 0) { items in
                if items.count == 0 { return }
                if items[0] is String {
                    return
                }
                let item = items[0] as! [String: Any]
                
                var user = cache
                
                if (cache?.id == item["id"] as? Int64) {
                    cache?.setData(item: item)
                } else {
                    user = NSEntityDescription.insertNewObject(forEntityName: "User", into: self.managedContext) as? User
                    user!.setData(item: item)
                }
                
                do {
                    try self.managedContext.save()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }

                emitter.onNext(user!)
            }
    }

}
