//
//  ViewController.swift
//  RoboController
//
//  Created by Anthony Picciano on 1/14/17.
//  Copyright © 2017 Anthony Picciano. All rights reserved.
//

import Cocoa
import GameController

class ViewController: NSViewController {
    
    @IBOutlet weak var leftThrustLabel: NSTextField!
    @IBOutlet weak var rightThrustLabel: NSTextField!
    @IBOutlet weak var leftThrustSlider: NSSlider!
    @IBOutlet weak var rightThrustSlider: NSSlider!
    @IBOutlet weak var aButton: ButtonIndicator!
    @IBOutlet weak var bButton: ButtonIndicator!
    @IBOutlet weak var xButton: ButtonIndicator!
    @IBOutlet weak var yButton: ButtonIndicator!
    @IBOutlet weak var serialConnectionWarningLabel: NSTextField!
    
    var connectedGameController: GCController?
    var motorValuesChanged = false
    var skippedLastTimerEvent = false
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(foundConnector(notification:)), name: NSNotification.Name.GCControllerDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(lostConnector(notification:)), name: NSNotification.Name.GCControllerDidDisconnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didConnectHandler(notification:)), name: SerialConnectionDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didDisconnectHandler(notification:)), name: SerialConnectionDidDisconnect, object: nil)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func foundConnector(notification: Notification) {
        connectedGameController = notification.object as? GCController
        
        debugPrint("Found controller: \(connectedGameController?.vendorName ?? "Vendor name is missing.")")
        
        connectedGameController?.controllerPausedHandler = { controller in
            debugPrint("MENU pressed.")
        }
        
        if let profile = connectedGameController?.extendedGamepad {
            
            profile.leftThumbstick.yAxis.valueChangedHandler = { (axis, value) in
                let value = Int(axis.value * 255.0)
                self.leftThrustLabel.stringValue = "\(value)"
                self.leftThrustSlider.intValue = Int32(value)
                
                self.motorValuesChanged = true
                
                if self.skippedLastTimerEvent || value == 0 {
                    self.sendMotorSpeed()
                }
            }
            
            profile.rightThumbstick.yAxis.valueChangedHandler = { (axis, value) in
                let value = Int(axis.value * 255.0)
                self.rightThrustLabel.stringValue = "\(-value)"
                self.rightThrustSlider.intValue = Int32(value)
                
                self.motorValuesChanged = true
                
                if self.skippedLastTimerEvent || value == 0 {
                    self.sendMotorSpeed()
                }
            }
            
            profile.buttonA.pressedChangedHandler = { (button, value, pressed) in
                self.aButton.on = pressed
                
                if pressed {
                    if !SerialConnection.shared.send(message: "sw\n") {
                        self.showWarning()
                    }
                }
            }
            
            profile.buttonB.pressedChangedHandler = { (button, value, pressed) in
                self.bButton.on = pressed
                
                if pressed {}
            }
            
            profile.buttonX.pressedChangedHandler = { (button, value, pressed) in
                self.xButton.on = pressed
                
                if pressed {}
            }
            
            profile.buttonY.pressedChangedHandler = { (button, value, pressed) in
                self.yButton.on = pressed
                
                if pressed {}
            }
            
            profile.leftTrigger.pressedChangedHandler = { (button, value, pressed) in
                if pressed {
                    debugPrint("Brakes")
                    let result = SerialConnection.shared.send(message: "stop\n")
                    debugPrint(result ? "Message sent." : "Send failed.")
                }
            }
            
            profile.rightTrigger.pressedChangedHandler = { (button, value, pressed) in
                if pressed {
                    debugPrint("Firestick activated!!!")
                    let result = SerialConnection.shared.send(message: "move 1\n")
                    debugPrint(result ? "Message sent." : "Send failed.")
                }
            }
        }
    }
    
    func sendMotorSpeed() {
        guard SerialConnection.shared.isConnected else {
            return
        }
        
        guard motorValuesChanged else {
            skippedLastTimerEvent = true
            return
        }
        
        skippedLastTimerEvent = false
        
        if let profile = connectedGameController?.extendedGamepad {
            let leftValue = Int(profile.leftThumbstick.yAxis.value * 255.0)
            let rightValue = Int(profile.rightThumbstick.yAxis.value * 255.0)
            
            motorValuesChanged = false
            
            if !SerialConnection.shared.send(message: "M\(leftValue) \(rightValue)") {
                self.showWarning()
            }
        }
    }
    
    func lostConnector(notification: Notification) {
        debugPrint("Lost controller.")
    }
    
    func didConnectHandler(notification: Notification) {
        serialConnectionWarningLabel.isHidden = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            self.sendMotorSpeed()
        }
    }
    
    func didDisconnectHandler(notification: Notification) {
        serialConnectionWarningLabel.isHidden = false
        
        timer?.invalidate()
    }
    
    func showWarning() {
        
    }

}

