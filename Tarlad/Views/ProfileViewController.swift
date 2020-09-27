//
//  ProfileViewController.swift
//  Tarlad
//
//  Created by Taras Kulyavets on 20.09.2020.
//  Copyright © 2020 Tarlad. All rights reserved.
//

import UIKit
import CoreData

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let logout = UIBarButtonItem(title: "Logout", style: .plain,
            target: self,
            action: #selector(self.logout)
        )
        
        navigationItem.setRightBarButtonItems([logout], animated: false)
    }
    
    @IBAction func unwindToProfile(unwindSegue: UIStoryboardSegue) {
        
    }
    
    @objc func logout(_ sender: UIButton) {

        UserDefaults.standard.removeObject(forKey: "USERID")
        UserDefaults.standard.removeObject(forKey: "TOKEN")
        SocketIO.shared.socket.disconnect()
        performSegue(withIdentifier: "auth", sender: self)
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let persistentContainer = appDelegate.persistentContainer
        let context = persistentContainer.viewContext
        let entityNames = persistentContainer.managedObjectModel.entities.map({ $0.name!})
        entityNames.forEach { entityName in
            let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)

            do {
                try context.execute(deleteRequest)
                try context.save()
            } catch {
                
            }
        }
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
