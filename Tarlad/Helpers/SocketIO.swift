//
//  SocketHelper.swift
//  Tarlad
//
//  Created by Taras Kulyavets on 20.09.2020.
//  Copyright © 2020 Tarlad. All rights reserved.
//

import SocketIO

class SocketIO {
    
    public static let shared = SocketIO()
    
    public var manager: SocketManager
    public var socket: SocketIOClient
    
    init() {
        manager = SocketManager(socketURL: URL(string:"http://192.168.1.116:3000/")!, config: [.reconnects(true), .reconnectWait(1), .reconnectWaitMax(5)])
        socket = manager.defaultSocket
    }
    
    func setToken(token: String) {
        manager = SocketManager(socketURL: URL(string:"http://192.168.1.116:3000/")!, config: [.reconnects(true), .reconnectWait(1), .reconnectWaitMax(5), .extraHeaders(["Authorization": "Bearer \(token)"])])
        socket = manager.defaultSocket
        
        socket.on(clientEvent: .connect, callback: { _, _ in
            self.socket.emit("join")
        })
        
        socket.on("join", callback: { _, _ in
            self.socket.emit("join")
        })
    }
    
}
