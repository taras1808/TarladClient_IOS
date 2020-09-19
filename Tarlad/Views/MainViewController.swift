//
//  MainViewController.swift
//  Tarlad
//
//  Created by Taras Kulyavets on 19.09.2020.
//  Copyright © 2020 Tarlad. All rights reserved.
//

import UIKit
import Alamofire

class MainViewController: UIViewController {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let chats: [Token] = [ Token(value: "dsfdvdf", userId: 1),
    Token(value: "2132", userId: 1),
    Token(value: "32f34v", userId: 1),
    Token(value: "v45v", userId: 1),
    Token(value: "3crvc", userId: 1),
    Token(value: "v4btrv", userId: 1)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.title = "Tarlad"
        
//        let image: UIImage = UIImage(named: "lamborghini")!
//        let imageView = UIImageView(image: image)
//        imageView.contentMode = .scaleAspectFit
//        tabBarController?.navigationItem.titleView = imageView
        
        let logout = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonItem.SystemItem.stop,
            target: self,
            action: #selector(self.logout)
        )
        
        tabBarController?.navigationItem.setRightBarButtonItems([logout], animated: true)
        
        
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.register(UINib(nibName: "ChatCell", bundle: nil), forCellWithReuseIdentifier: "ChatCell")
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
    
        
    }
    
    @objc func logout(_ sender: UIButton) {
        UserDefaults.standard.removeObject(forKey: "TOKEN")
        performSegue(withIdentifier: "auth", sender: self)
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


extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chats.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChatCell", for: indexPath) as! ChatCell
        cell.label.text = chats[indexPath.item].value
        cell.backgroundColor = .gray
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 100)
    }
    
    
    
}
