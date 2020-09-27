//
//  Extensions.swift
//  Tarlad
//
//  Created by Taras Kulyavets on 26.09.2020.
//  Copyright © 2020 Tarlad. All rights reserved.
//

import UIKit

extension UIImageView {

    func makeRounded() {

        self.layer.masksToBounds = false
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
}
