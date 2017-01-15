//
//  AppDelegate.swift
//  RoboController
//
//  Created by Anthony Picciano on 1/14/17.
//  Copyright © 2017 Anthony Picciano. All rights reserved.
//

import Cocoa
import GameController

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {


    @IBAction func connectToControllerAction(_ sender: Any) {
        debugPrint("Connecting to Controller...")
        
        GCController.startWirelessControllerDiscovery {
            debugPrint("Stopped looking for controllers.")
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

