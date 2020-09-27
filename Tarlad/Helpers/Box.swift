//
//  Box.swift
//  Tarlad
//
//  Created by Taras Kulyavets on 24.09.2020.
//  Copyright © 2020 Tarlad. All rights reserved.
//

final class Box<T> {

    typealias Listener = (T) -> Void
    var listener: Listener?

    var value: T {
        didSet {
            listener?(value)
        }
    }

    init(_ value: T) {
        self.value = value
    }

    func bind(listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
}
