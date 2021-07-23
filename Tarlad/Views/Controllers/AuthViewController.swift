//
//  AuthViewController.swift
//  Tarlad
//
//  Created by Taras Kulyavets on 14.09.2020.
//  Copyright © 2020 Tarlad. All rights reserved.
//

import UIKit
import Alamofire
import SocketIO

class AuthViewController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func unwindToLogin(unwindSegue: UIStoryboardSegue) {
    }
    
    @IBAction func login(_ sender: Any) {
        
        let login = LoginCreditentals(
            email: email.text,
            password: password.text
        )
        
        
        AF.request("http://192.168.1.116:3000/api/accounts/authorize",
           method: .post,
           parameters: login,
           encoder: JSONParameterEncoder.default).response { response in
            if (response.error != nil && response.data != nil) { return }

            guard let token = try? JSONDecoder().decode(TokenDTO.self, from: response.data ?? "".data(using: .utf8)!) else { return }

            UserDefaults.standard.set(token.token, forKey: "TOKEN")
            
            UserDefaults.standard.set(token.refreshToken.userId, forKey: "USERID")
            
            SocketIO.shared.setToken(token: token.token)
            
            SocketIO.shared.socket.connect()
            
            
            self.performSegue(withIdentifier: "backToMain", sender: self)
        }
    }
}
