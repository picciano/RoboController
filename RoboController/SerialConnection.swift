//
//  SerialConnection.swift
//  RoboController
//
//  Created by Oscar Picciano on 1/15/17.
//  Copyright © 2017 Oscar Picciano. All rights reserved.
//

import Foundation
import ORSSerial

let SerialConnectionDidConnect = NSNotification.Name("SerialConnectionDidConnect")
let SerialConnectionDidDisconnect = NSNotification.Name("SerialConnectionDidDisconnect")
let LeftBumperHit = NSNotification.Name("LeftBumperHit")
let RightBumperHit = NSNotification.Name("RightBumperHit")

class SerialConnection: NSObject, ORSSerialPortDelegate {
    
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
                    
                    selectedPort.delegate = self
                    
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
    
    func serialPortWasRemoved(fromSystem serialPort: ORSSerialPort) {
        selectedPort?.close()
        NotificationCenter.default.post(name: SerialConnectionDidDisconnect, object: self)
    }
    
    var buffer: String = String()
    
    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
        if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String {
            
            buffer.append(string)
            
            if string.hasSuffix("\r\n") {
                
                if buffer.hasPrefix("Left bumper") {
                    NotificationCenter.default.post(name: LeftBumperHit, object: self)
                } else if buffer.hasPrefix("Right bumper") {
                    NotificationCenter.default.post(name: RightBumperHit, object: self)
                } else {
                    print(buffer)
                }
                buffer = String()
            }
            
        }
    }
}
