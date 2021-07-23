//
//  MessageCell.swift
//  Tarlad
//
//  Created by Taras Kulyavets on 04.10.2020.
//  Copyright © 2020 Tarlad. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {

    @IBOutlet weak var nickname: UILabel!
    @IBOutlet weak var message: UITextView!
    
    @IBOutlet weak var chatImage: UIImageView! {
        didSet {
            chatImage.makeRounded()
        }
    }

}
