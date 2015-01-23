// Playground - noun: a place where people can play

import Foundation
import AppKit

extension NSBezierPath {
    func printPoints() {
        for var i = 0; i < self.elementCount; i++ {
            var points = ContiguousArray(count: 3, repeatedValue: NSZeroPoint)
            points.withUnsafeMutableBufferPointer {
                (bufferPointer) -> Void in
                let ele = self.elementAtIndex(i, associatedPoints: bufferPointer.baseAddress)
            }
            print("Point \(i): ")
            for point in points { print(point) }
            println()
            //    switch ele {
            //    case .MoveTo: println("Move To: \(points)")
            //    case NSLineToBezierPathElement: println("Move To: \(points)")
            //    case NSCurveToBezierPathElement: println("Move To: \(points)")
            //    case NSClosePathBezierPathElement: println("Move To: \(points)")
            //    }
        }
    }
}

var dirtyRect = NSRect(
    origin: NSZeroPoint,
    size: NSSize(
        width: 500,
        height: 100
    )
)

let bubbleFillColor = NSColor(hue: (210.0 / 360.0),
    saturation: 0.94,
    brightness: 1.0,
    alpha: 1.0)
let xRadius: CGFloat = 30.0
let yRadius: CGFloat = 30.0

let width = dirtyRect.size.width
let height = dirtyRect.size.height

let xRH = xRadius/2
let xK = 0.552228474 * xRadius
let xKH = xK/2
let yK = 0.552228474 * yRadius
let yKH = yK/2

var path = NSBezierPath()
path.moveToPoint(NSPoint(x: 0.0, y: yRadius))
path.curveToPoint(NSPoint(x: xRadius, y: 0.0),
    controlPoint1: NSPoint(x: 0.0, y: yRadius-yK),
    controlPoint2: NSPoint(x: xRadius-xK, y: 0.0))
path.lineToPoint(NSPoint(x: width-xRH-xRadius, y: 0.0))

//path.curveToPoint(NSPoint(x: width-xRH-(xRadius/2), y: yRadius/2),
//    controlPoint1: NSPoint(x: width-xRadius-xRH+xKH, y: 0.0),
//    controlPoint2: NSPoint(x: width-xRH-(xRadius/2), y: (yRadius/2)-yKH))
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

//println("Points:")
//path.printPoints()

let imageSize = dirtyRect.size
let imageFrame = dirtyRect
let bubbleImage = NSImage(size: imageSize, flipped: false) {
    (rect) in
    bubbleFillColor.setFill()
    path.fill()
    return true
}

var pathF = NSBezierPath()
pathF.moveToPoint(NSPoint(x: xRH, y: yRadius))

pathF.curveToPoint(NSPoint(x: 0.0, y: 0.0),
    controlPoint1: NSPoint(x: xRH, y: yRadius-yK),
    controlPoint2: NSPoint(x: xK, y: 0.0))
pathF.curveToPoint(NSPoint(x: xRH+xRadius-(xRadius/2), y: yRadius/2),
    controlPoint1: NSPoint(x: (xRadius/2), y: 0),
    controlPoint2: NSPoint(x: xRH+xRadius-(xRadius/2), y: (yRadius/2)-yK))
pathF.lineToPoint(NSPoint(x: xRH, y: yRadius))

pathF.curveToPoint(NSPoint(x: xRadius+xRH, y: 0.0),
    controlPoint1: NSPoint(x: xRH, y: yRadius-yK),
    controlPoint2: NSPoint(x: xRadius-xK, y: 0.0))

pathF.lineToPoint(NSPoint(x: width-xRadius, y: 0.0))

pathF.curveToPoint(NSPoint(x: width, y: yRadius),
    controlPoint1: NSPoint(x: width-xRadius+xK, y: 0.0),
    controlPoint2: NSPoint(x: width, y: yRadius-yK))

pathF.lineToPoint(NSPoint(x: width, y: height-yRadius))
pathF.curveToPoint(NSPoint(x: width-xRadius, y: height),
    controlPoint1: NSPoint(x: width, y: height-yRadius+yK),
    controlPoint2: NSPoint(x: width-xRadius+xK, y: height))
pathF.lineToPoint(NSPoint(x: xRH+xRadius, y: height))
pathF.curveToPoint(NSPoint(x: xRH, y: height-yRadius),
    controlPoint1: NSPoint(x: xRH+xRadius-xK, y: height),
    controlPoint2: NSPoint(x: xRH, y: height-yRadius+yK))
pathF.closePath()

//println("Points:")
//path.printPoints()

let imageFSize = dirtyRect.size
let imageFFrame = dirtyRect
let bubbleFImage = NSImage(size: imageFSize, flipped: false) {
    (rect) in
    bubbleFillColor.setFill()
    pathF.fill()
    return true
}

