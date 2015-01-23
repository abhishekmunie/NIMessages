//
//  MessageBubbleView.swift
//  NIMessages
//
//  Created by Abhishek Munie on 06/11/14.
//  Copyright (c) 2014 Abhishek Munie. All rights reserved.
//

import Cocoa

@IBDesignable
class MessageBubbleView: NSView {
    
    enum Type {
        case Left, Right
    }
    
    let leftDefaultColor = NSColor.whiteColor().am0_colorByDarkeningColorWithValue(0.12).colorWithAlphaComponent(0.92)
    let rightDefaultColor = NSColor(hue: (210.0 / 360.0),
        saturation: 0.94,
        brightness: 1.0,
        alpha: 0.92)

    @IBInspectable var t: MessageBubbleType = .Left
    @IBInspectable var isRightSided: Bool = false { didSet { type = isRightSided ? .Right : .Left } }
    @IBInspectable var type: Type = .Left { didSet { bezierPathCache = nil } }
    @IBInspectable var color: NSColor? = nil
    @IBInspectable var xRadius: CGFloat = 12.0 { didSet { bezierPathCache = nil } }
    @IBInspectable var yRadius: CGFloat = 12.0 { didSet { bezierPathCache = nil } }
    
    let K: CGFloat = 0.552228474
    
    var bezierPathCache: NSBezierPath?
    var bezierPathCacheSize: NSSize?
    
    func createLeftBezierPathOfSize(size: NSSize) -> NSBezierPath {
        if let path = self.bezierPathCache {
            if let lastSize = self.bezierPathCacheSize {
                if size == lastSize {
                    return path
                }
            }
        }
        
        let width = size.width
        let height = size.height
        
        let xRH = xRadius/2
        let xK = K * xRadius
        let xKH = xK/2
        let yK = K * yRadius
        let yKH = yK/2
        
        let path = NSBezierPath()
        path.moveToPoint(NSPoint(x: xRH, y: yRadius))
        
        path.curveToPoint(NSPoint(x: 0.0, y: 0.0),
            controlPoint1: NSPoint(x: xRH, y: yRadius-yK),
            controlPoint2: NSPoint(x: xK, y: 0.0))
        path.curveToPoint(NSPoint(x: xRH+xRadius-(xRadius/2), y: yRadius/2),
            controlPoint1: NSPoint(x: (xRadius/2), y: 0),
            controlPoint2: NSPoint(x: xRH+xRadius-(xRadius/2), y: (yRadius/2)-yK))
        path.lineToPoint(NSPoint(x: xRH, y: yRadius))
        
        path.curveToPoint(NSPoint(x: xRadius+xRH, y: 0.0),
            controlPoint1: NSPoint(x: xRH, y: yRadius-yK),
            controlPoint2: NSPoint(x: xRadius-xK, y: 0.0))
        
        path.lineToPoint(NSPoint(x: width-xRadius, y: 0.0))
        
        path.curveToPoint(NSPoint(x: width, y: yRadius),
            controlPoint1: NSPoint(x: width-xRadius+xK, y: 0.0),
            controlPoint2: NSPoint(x: width, y: yRadius-yK))
        
        path.lineToPoint(NSPoint(x: width, y: height-yRadius))
        path.curveToPoint(NSPoint(x: width-xRadius, y: height),
            controlPoint1: NSPoint(x: width, y: height-yRadius+yK),
            controlPoint2: NSPoint(x: width-xRadius+xK, y: height))
        path.lineToPoint(NSPoint(x: xRH+xRadius, y: height))
        path.curveToPoint(NSPoint(x: xRH, y: height-yRadius),
            controlPoint1: NSPoint(x: xRH+xRadius-xK, y: height),
            controlPoint2: NSPoint(x: xRH, y: height-yRadius+yK))
        path.closePath()
        
        let flattenedPath = path.bezierPathByFlatteningPath
        self.bezierPathCache = flattenedPath
        self.bezierPathCacheSize = size
        
        return flattenedPath
    }
    
    func createRightBezierPathOfSize(size: NSSize) -> NSBezierPath {
        if let path = self.bezierPathCache {
            if let lastSize = self.bezierPathCacheSize {
                if size == lastSize {
                    return path
                }
            }
        }
        
        let width = size.width
        let height = size.height
        
        let xRH = xRadius/2
        let xK = 0.552228474 * xRadius
        let xKH = xK/2
        let yK = 0.552228474 * yRadius
        let yKH = yK/2
        
        let path = NSBezierPath()
        path.moveToPoint(NSPoint(x: 0.0, y: yRadius))
        path.curveToPoint(NSPoint(x: xRadius, y: 0.0),
            controlPoint1: NSPoint(x: 0.0, y: yRadius-yK),
            controlPoint2: NSPoint(x: xRadius-xK, y: 0.0))
        path.lineToPoint(NSPoint(x: width-xRH-xRadius, y: 0.0))
        
        path.curveToPoint(NSPoint(x: width-xRH, y: yRadius),
            controlPoint1: NSPoint(x: width-xRH-xRadius+xK, y: 0.0),
            controlPoint2: NSPoint(x: width-xRH, y: yRadius-yK))
        path.lineToPoint(NSPoint(x: width-xRH-(xRadius/2), y: yRadius/2))
        
        path.curveToPoint(NSPoint(x: width, y: 0.0),
            controlPoint1: NSPoint(x: width-xRH-(xRadius/2), y: (yRadius/2)-yK),
            controlPoint2: NSPoint(x: width-xKH, y: 0.0))
        path.curveToPoint(NSPoint(x: width-xRH, y: yRadius),
            controlPoint1: NSPoint(x: width-xK, y: 0.0),
            controlPoint2: NSPoint(x: width-xRH, y: yRadius-yK))
        
        path.lineToPoint(NSPoint(x: width-xRH, y: height-yRadius))
        path.curveToPoint(NSPoint(x: width-xRH-xRadius, y: height),
            controlPoint1: NSPoint(x: width-xRH, y: height-yRadius+yK),
            controlPoint2: NSPoint(x: width-xRH-xRadius+xK, y: height))
        path.lineToPoint(NSPoint(x: xRadius, y: height))
        path.curveToPoint(NSPoint(x: 0.0, y: height-yRadius),
            controlPoint1: NSPoint(x: xRadius-xK, y: height),
            controlPoint2: NSPoint(x: 0.0, y: height-yRadius+yK))
        path.closePath()
        
        let flattenedPath = path.bezierPathByFlatteningPath
        self.bezierPathCache = flattenedPath
        self.bezierPathCacheSize = size
        
        return flattenedPath
    }
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        layer?.borderWidth = 15
////        layer.borderColor = NSColor.blackColor().CGColor
////        layer.cornerRadius = 24
////        clipsToBounds = true
//    }
//    override var intrinsicContentSize: CGSize {
//        let intrinsicSize = super.intrinsicContentSize
//    
//        return CGSize(width: intrinsicSize.width + (2 * xRadius),
//            height: intrinsicSize.height + (2 * yRadius))
//    }
    
//    override var alignmentRectInsets: NSEdgeInsets {
//        return NSEdgeInsetsMake(yRadius, xRadius, yRadius, xRadius)
//    }
    
    override func drawRect(dirtyRect: NSRect) {
        var path: NSBezierPath
        var bubbleFillColor: NSColor
        
        switch self.type {
        case .Left:
            path = createLeftBezierPathOfSize(dirtyRect.size)
            bubbleFillColor = color ?? leftDefaultColor
        case .Right:
            path = createRightBezierPathOfSize(dirtyRect.size)
            bubbleFillColor = color ?? rightDefaultColor
        }
        
        bubbleFillColor.setFill()
        path.fill()
        
        //self.layer?.borderWidth = 15
        
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
    }
    
}
