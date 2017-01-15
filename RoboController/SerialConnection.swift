//
//  SerialConnection.swift
//  RoboController
//
//  Created by Anthony Picciano on 1/15/17.
//  Copyright © 2017 Anthony Picciano. All rights reserved.
//

import Foundation
import ORSSerial

class SerialConnection {
    
    static let shared = SerialConnection()
    
    var selectedPort: ORSSerialPort? {
        willSet {
            selectedPort?.close()
        }
        didSet {
            debugPrint("Serial port is now \(selectedPort?.path)")
            
            selectedPort?.baudRate = 9600
            selectedPort?.open()
        }
    }
    
    func send(message: String) -> Bool {
        if let data = message.data(using: .utf8) {
            return selectedPort?.send(data) ?? false
        }
        
        return false
    }
}
