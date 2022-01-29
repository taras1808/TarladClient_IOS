//
//  ChatCell.swift
//  Tarlad
//
//  Created by Taras Kulyavets on 26.09.2020.
//  Copyright © 2020 Tarlad. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {
    
    var chatId: Int?

    @IBOutlet weak var chatImage: UIImageView! {
        didSet {
            chatImage.makeRounded()
        }
    }
        
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var message: UILabel!
}
