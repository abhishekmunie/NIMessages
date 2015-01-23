//
//  MessageRowView.swift
//  NIMessages
//
//  Created by Abhishek Munie on 05/11/14.
//  Copyright (c) 2014 Abhishek Munie. All rights reserved.
//

import Cocoa

class MessageRowView: NSTableRowView {
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        // Drawing code here.
    }
    
    override var selected: Bool {
        didSet {
            if selected {
            } else {
            }
        }
    }
    
    
    override func drawSelectionInRect(dirtyRect: NSRect) {
//        if self.selectionHighlightStyle != .None {
//            let selectionRect: NSRect = NSInsetRect(self.bounds, 5.5, 5.5)
//            NSColor(calibratedWhite: 0.72, alpha: 1.0).setStroke()
//            NSColor(calibratedWhite: 0.82, alpha: 1.0).setFill()
//            let selectionPath = NSBezierPath(roundedRect: selectionRect, xRadius: 10, yRadius: 10)
//            selectionPath.fill()
//            selectionPath.stroke()
//        }
    }
}
