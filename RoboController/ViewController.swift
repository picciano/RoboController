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
    @IBOutlet weak var aButton: NSButton!
    
    var connectedGameController: GCController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(foundConnector(notification:)), name: NSNotification.Name.GCControllerDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(lostConnector(notification:)), name: NSNotification.Name.GCControllerDidDisconnect, object: nil)
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
            }
            
            profile.rightThumbstick.yAxis.valueChangedHandler = { (axis, value) in
                let value = Int(axis.value * 255.0)
                self.rightThrustLabel.stringValue = "\(-value)"
                self.rightThrustSlider.intValue = Int32(value)
            }
            
            profile.buttonA.pressedChangedHandler = { (button, value, pressed) in
                self.aButton.state = pressed ? NSOnState : NSOffState
                
                if pressed {
                    debugPrint("Play small world.")
                    let result = SerialConnection.shared.send(message: "sw\n")
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
    
    func lostConnector(notification: Notification) {
        debugPrint("Lost controller.")
    }

}

