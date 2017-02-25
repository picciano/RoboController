//
//  ViewController.swift
//  RoboController
//
//  Created by Oscar Picciano on 1/14/17.
//  Copyright © 2017 Oscar Picciano. All rights reserved.
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
    
    @IBOutlet weak var leftBumperLabel: NSTextField!
    @IBOutlet weak var rightBumperLabel: NSTextField!
    
    var connectedGameController: GCController?
    var motorValuesChanged = false
    var skippedLastTimerEvent = false
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideBumperLabels()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(foundConnector(notification:)), name: NSNotification.Name.GCControllerDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(lostConnector(notification:)), name: NSNotification.Name.GCControllerDidDisconnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didConnectHandler(notification:)), name: SerialConnectionDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didDisconnectHandler(notification:)), name: SerialConnectionDidDisconnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(leftBumperHitHandler(notification:)), name: LeftBumperHit, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(rightBumperHitHandler(notification:)), name: RightBumperHit, object: nil)
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
                
                if pressed {
                    _ = SerialConnection.shared.send(message: "acc\n")
                }
            }
            
            profile.leftShoulder.pressedChangedHandler = { (button, value, pressed) in
                if pressed {
                    _ = SerialConnection.shared.send(message: "stop\n")
                }
            }
            
            profile.leftTrigger.valueChangedHandler = { (button, value, pressed) in
                let value = Int(button.value * 255.0)
                
                self.leftThrustLabel.stringValue = "\(-value)"
                self.leftThrustSlider.intValue = Int32(-value)
                self.rightThrustLabel.stringValue = "\(-value)"
                self.rightThrustSlider.intValue = Int32(-value)
                
                self.motorValuesChanged = true
                
                if self.skippedLastTimerEvent || value == 0 {
                    self.sendMotorSpeed()
                }
            }
            
            profile.rightTrigger.valueChangedHandler = { (button, value, pressed) in
                let value = Int(button.value * 255.0)
                
                self.leftThrustLabel.stringValue = "\(value)"
                self.leftThrustSlider.intValue = Int32(value)
                self.rightThrustLabel.stringValue = "\(value)"
                self.rightThrustSlider.intValue = Int32(value)
                
                self.motorValuesChanged = true
                
                if self.skippedLastTimerEvent || value == 0 {
                    self.sendMotorSpeed()
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
            var leftValue = Int(profile.leftThumbstick.yAxis.value * 255.0)
            var rightValue = Int(profile.rightThumbstick.yAxis.value * 255.0)
            
            leftValue = leftValue + Int(profile.rightTrigger.value * 255.0)
            rightValue = rightValue + Int(profile.rightTrigger.value * 230.0)
            
            leftValue = leftValue + Int(profile.leftTrigger.value * -255.0)
            rightValue = rightValue + Int(profile.leftTrigger.value * -238.0)
            
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
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            self.sendMotorSpeed()
        }
    }
    
    func didDisconnectHandler(notification: Notification) {
        serialConnectionWarningLabel.isHidden = false
        
        timer?.invalidate()
    }
    
    func leftBumperHitHandler(notification: Notification) {
        leftBumperLabel.isHidden = false
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.perform(#selector(hideBumperLabels), with: nil, afterDelay: 1.0)
    }
    
    func rightBumperHitHandler(notification: Notification) {
        rightBumperLabel.isHidden = false
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.perform(#selector(hideBumperLabels), with: nil, afterDelay: 1.0)
    }
    
    func hideBumperLabels() {
        leftBumperLabel.isHidden = true
        rightBumperLabel.isHidden = true
    }
    
    func showWarning() {
        debugPrint("Unable to send command.")
    }

}

