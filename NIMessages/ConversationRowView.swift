//
//  ConversationRowView.swift
//  NIMessages
//
//  Created by Abhishek Munie on 21/10/14.
//  Copyright (c) 2014 Abhishek Munie. All rights reserved.
//

import Cocoa

class ConversationRowView: NSTableRowView {

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        
    }
    
    override var selected: Bool {
        didSet {
            if selected {
//            let cellView = self.viewAtColumn(0) as NSTableCellView
//            cellView.imageView?.layer?.masksToBounds = true
//            cellView.imageView?.layer?.cornerRadius = 5.0
//            if let textField = cellView.textField {
//                let fontSize = textField.font?.pointSize ?? 14
//                if self.selected {
//                    textField.font = NSFont.boldSystemFontOfSize(fontSize)
//                } else {
//                    textField.font = NSFont.systemFontOfSize(fontSize)
//                }
//            }
            }
        }
    }
    
//    override var interiorBackgroundStyle: NSBackgroundStyle {
//        return .Light
//    }
//    
//    override func drawSelectionInRect(dirtyRect: NSRect) {
//        if self.selectionHighlightStyle != .None {
//            let selectionRect: NSRect = NSInsetRect(self.bounds, 5.5, 5.5)
//            NSColor(calibratedWhite: 0.72, alpha: 1.0).setStroke()
//            NSColor(calibratedWhite: 0.82, alpha: 1.0).setFill()
//            let selectionPath = NSBezierPath(roundedRect: selectionRect, xRadius: 10, yRadius: 10)
//            selectionPath.fill()
//            selectionPath.stroke()
//        }
//    }
//    
//    private var ta: NSTrackingArea?
//    
//    override func updateTrackingAreas() {
//        super.updateTrackingAreas()
//        
//        let _ta: NSTrackingArea = ta ?? NSTrackingArea(rect: NSZeroRect, options: nil, owner: self, userInfo: nil)
//        if !(self.trackingAreas as NSArray).containsObject(_ta) {
//            self.addTrackingArea(_ta)
//        }
//    }
//    
//    private var _mouseInside: Bool = false {
//        didSet {
//            self.needsDisplay = true
//        }
//    }
//    
//    override func mouseEntered(theEvent: NSEvent) {
//        _mouseInside = true
//    }
//    
//    override func mouseExited(theEvent: NSEvent) {
//        _mouseInside = false
//    }
//    
//    override func drawBackgroundInRect(dirtyRect: NSRect) {
//        self.backgroundColor.set()
//        NSRectFill(self.bounds)
//        
//        if _mouseInside {
//            let gradient = gradientWithTargetColor(NSColor.whiteColor())
//            gradient.drawInRect(self.bounds, angle: 0)
//        }
//    }
//    
    override func drawSeparatorInRect(dirtyRect: NSRect) {
        DrawSeparatorInRect(self.separatorRect)
    }

    var separatorRect: NSRect {
        var rect = self.bounds
        rect.origin.y = NSMaxY(rect) - 1
        rect.size.height = 1
        return rect
    }

//    override var frame: NSRect {
//        didSet {
//            if (self.inLiveResize) {
//                // Redraw everything if we are using a gradient
//                if (self.selected || self._mouseInside) {
//                    self.needsDisplay = true
//                } else {
//                    // Redraw our horizontal grid line, which is a gradient
//                    self.setNeedsDisplayInRect(self.separatorRect)
//                }
//            }
//        }
//    }

}


private func gradientWithTargetColor(targetColor: NSColor) -> NSGradient {
    var colors: NSArray = [targetColor.colorWithAlphaComponent(0), targetColor, targetColor, targetColor.colorWithAlphaComponent(0)]
    let locations: [CGFloat] = [ 0.0, 0.35, 0.65, 1.0 ]
    return NSGradient(colors: colors, atLocations: locations, colorSpace: NSColorSpace.sRGBColorSpace())
}

// Cache the gradient for performance
private let sharedSeparatorGradient: NSGradient = gradientWithTargetColor(NSColor(SRGBRed: 0.80, green: 0.80, blue: 0.80, alpha: 1.0))

private func DrawSeparatorInRect(rect: NSRect) {
    let gradient = sharedSeparatorGradient
    gradient.drawInRect(rect, angle: 0)
}
