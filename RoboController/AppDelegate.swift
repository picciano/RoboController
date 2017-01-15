//
//  AppDelegate.swift
//  RoboController
//
//  Created by Anthony Picciano on 1/14/17.
//  Copyright © 2017 Anthony Picciano. All rights reserved.
//

import Cocoa
import GameController
import ORSSerial

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBAction func connectToControllerAction(_ sender: Any) {
        debugPrint("Connecting to Controller...")
        
        GCController.startWirelessControllerDiscovery {
            debugPrint("Stopped looking for controllers.")
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        listSerialPorts()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func listSerialPorts() {
        let ports = ORSSerialPortManager.shared().availablePorts
        let connectToPortItem = NSApplication.shared().mainMenu?.item(withTitle: "File")?.submenu?.item(withTitle: "Connect to Port")?.submenu
        
        for port in ports {
            let newItem = NSMenuItem(title: port.name, action: #selector(selectPort), keyEquivalent: "")
            newItem.representedObject = port
            connectToPortItem?.addItem(newItem)
        }
    }
    
    func selectPort(menuItem: NSMenuItem) {
        SerialConnection.shared.selectedPort = menuItem.representedObject as? ORSSerialPort
    }


}

