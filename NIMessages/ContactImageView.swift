//
//  ContactImageView.swift
//  NIMessages
//
//  Created by Abhishek Munie on 22/10/14.
//  Copyright (c) 2014 Abhishek Munie. All rights reserved.
//

import Cocoa



@IBDesignable
class ContactImageView: NSImageView {
    
    @IBInspectable
    var saturation: Float = 0.3
    
    private func circularImageFromImage(image: NSImage) -> NSImage {
        let rect = NSRect(origin: NSZeroPoint, size: image.size)
        let clipPath = NSBezierPath(ovalInRect: rect)
        
        let imageSize = image.size
        let clipedImage = NSImage(size: imageSize, flipped: false) { (rect) -> Bool in
            clipPath.addClip()
            image.drawInRect(rect, fromRect: NSZeroRect, operation: .CompositeSourceOver, fraction: 1.0)
            //            NSColor(white: 1.0, alpha: 1.0 - self.saturation).set()
            return true
        }
        return clipedImage
    }
    
    override var image: NSImage? {
        willSet (willSetImage) {
            if let newImage = willSetImage { clipped = false }
        }
    }
    
    private var clipped = false
    
    
    override func drawRect(dirtyRect: NSRect) {
        if let newImage = self.image {
            if !clipped {
                self.image = circularImageFromImage(newImage)
                clipped = true
            }
        }
        super.drawRect(dirtyRect)
//        setTranslatesAutoresizingMaskIntoConstraints:NO
//
    }

    
}
