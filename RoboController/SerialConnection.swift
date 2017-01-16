//
//  SerialConnection.swift
//  RoboController
//
//  Created by Anthony Picciano on 1/15/17.
//  Copyright © 2017 Anthony Picciano. All rights reserved.
//

import Foundation
import ORSSerial

let SerialConnectionDidConnect = NSNotification.Name("SerialConnectionDidConnect")
let SerialConnectionDidDisconnect = NSNotification.Name("SerialConnectionDidDisconnect")

class SerialConnection {
    
    static let shared = SerialConnection()
    
    var selectedPort: ORSSerialPort? {
        willSet {
            selectedPort?.close()
            NotificationCenter.default.post(name: SerialConnectionDidDisconnect, object: self)
        }
        didSet {
            if let selectedPort = selectedPort {
                selectedPort.baudRate = 9600
                
                DispatchQueue.global(qos: .userInitiated).async {
                    selectedPort.open()
                    
                    DispatchQueue.main.async(execute: { () -> Void in
                        NotificationCenter.default.post(name: SerialConnectionDidConnect, object: self)
                    })
                }
            }
        }
    }
    
    var isConnected: Bool {
        return selectedPort?.isOpen ?? false
    }
    
    func send(message: String) -> Bool {
        if let data = message.data(using: .utf8) {
            return selectedPort?.send(data) ?? false
        }
        
        return false
    }
}
