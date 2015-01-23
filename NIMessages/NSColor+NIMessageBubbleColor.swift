//
//  NSColor+NIMessageBubbleColor.swift
//  NIMessages
//
//  Created by Abhishek Munie on 06/11/14.
//  Copyright (c) 2014 Abhishek Munie. All rights reserved.
//

import Cocoa

extension NSColor {

    // Mark: - Message bubble colors
    
    class func am0_messageBubbleGreenColor() -> NSColor {
        return NSColor(hue: (130.0 / 360.0),
            saturation: 0.68,
            brightness: 0.80,
            alpha: 1.0)
    }
    
    class func am0_messageBubbleBlueColor() -> NSColor {
        return NSColor(hue: (210.0 / 360.0),
            saturation: 0.94,
            brightness: 1.0,
            alpha: 1.0)
    }
    
    class func am0__messageBubbleLightGrayColor() -> NSColor {
        return NSColor(hue: (240.0 / 360.0),
            saturation: 0.02,
            brightness: 0.92,
            alpha: 1.0)
    }
    
    // Mark: - Utilities
    
    func am0_colorByDarkeningColorWithValue(value: CGFloat) -> NSColor {
        let totalComponents = CGColorGetNumberOfComponents(self.CGColor)
        let isGreyscale = (totalComponents == 2) ? true : false
    
        let oldComponents = CGColorGetComponents(self.CGColor)
        let newComponents: [CGFloat] = isGreyscale ? [
            (oldComponents[0] - value < 0.0 ? 0.0 : oldComponents[0] - value),
            (oldComponents[0] - value < 0.0 ? 0.0 : oldComponents[0] - value),
            (oldComponents[0] - value < 0.0 ? 0.0 : oldComponents[0] - value),
            oldComponents[1]
        ] : [
            (oldComponents[0] - value < 0.0 ? 0.0 : oldComponents[0] - value),
            (oldComponents[1] - value < 0.0 ? 0.0 : oldComponents[1] - value),
            (oldComponents[2] - value < 0.0 ? 0.0 : oldComponents[2] - value),
            oldComponents[3]
        ]
    
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let newColor = CGColorCreate(colorSpace, newComponents)
    
        let retColor = NSColor(CGColor: newColor)

        return retColor
    }
}
