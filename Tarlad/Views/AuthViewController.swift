//
//  AuthViewController.swift
//  Tarlad
//
//  Created by Taras Kulyavets on 14.09.2020.
//  Copyright © 2020 Tarlad. All rights reserved.
//

import UIKit
import Alamofire

class AuthViewController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func unwindAction(unwindSegue: UIStoryboardSegue) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func login(_ sender: Any) {
        
        let login = LoginCreditentals(
            email: email.text,
            password: password.text
        )
        
        
        AF.request("http://192.168.0.108:3000/api/accounts/authorize",
                   method: .post,
                   parameters: login,
                   encoder: JSONParameterEncoder.default).response { response in
                    if (response.error != nil && response.data != nil) { return }

                    guard let token = try? JSONDecoder().decode(TokenDTO.self, from: response.data!) else { return }

                    print(token)

                    UserDefaults.standard.set(token.token, forKey: "TOKEN")
                    
                    self.dismiss(animated: true, completion: nil)
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
