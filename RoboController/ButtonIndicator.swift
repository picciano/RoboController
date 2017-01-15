//
//  ButtonIndicator.swift
//  RoboController
//
//  Created by Anthony Picciano on 1/15/17.
//  Copyright © 2017 Anthony Picciano. All rights reserved.
//

import Cocoa

@IBDesignable
class ButtonIndicator: NSView {
    
    @IBInspectable var on: Bool = false {
        didSet {
            setNeedsDisplay(bounds)
        }
    }
    
    @IBInspectable var labelText: String = "A" {
        didSet {
            setNeedsDisplay(bounds)
        }
    }
    
    override var frame: NSRect {
        didSet {
            setNeedsDisplay(bounds)
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        RoboControllerStyleKit.drawControllerButton(frame: bounds, resizing: .center, labelText: labelText, on: on)
    }
    
}
