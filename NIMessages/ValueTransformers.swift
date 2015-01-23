//
//  ValueTransformers.swift
//  NIMessages
//
//  Created by Abhishek Munie on 04/09/14.
//  Copyright (c) 2014 Abhishek Munie. All rights reserved.
//

import Cocoa

@objc(NSImageToNSDataTransformer)
public class NSImageToNSDataTransformer: NSValueTransformer {
    
    public override class func transformedValueClass() -> AnyClass { return NSData.self }
    
    public override class func allowsReverseTransformation() -> Bool { return true }
    
    public override func transformedValue(value: AnyObject?) -> AnyObject? {
        var data: NSData? = nil
        if let image = value as? NSImage {
            data = image.TIFFRepresentation
        }
        return data
    }
    
    public override func reverseTransformedValue(value: AnyObject?) -> AnyObject? {
        var image: NSImage? = nil
        if let data = value as? NSData {
            image = NSImage(data: data)
        }
        return image
    }
}

@objc(OptionalToBoolTransformer)
public class OptionalToBoolTransformer: NSValueTransformer {
    
    public override class func transformedValueClass() -> AnyClass { return NSNumber.self }
    
    public override func transformedValue(value: AnyObject?) -> AnyObject? {
        return (value != nil) as NSNumber
    }
}

@objc public class NSNetServiceToNSDataTransformer: NSValueTransformer {
    
    public override class func transformedValueClass() -> AnyClass { return NSData.self }
    
    public override class func allowsReverseTransformation() -> Bool { return true }
    
    public override func transformedValue(value: AnyObject?) -> AnyObject? {
        var data: NSData? = nil
        if let netService = value as? NSNetService {
            data = NSArchiver.archivedDataWithRootObject(netService)
        }
        return data
    }
    
    public override func reverseTransformedValue(value: AnyObject?) -> AnyObject? {
        var netService: NSNetService? = nil
        if let data = value as? NSData {
            netService = NSUnarchiver.unarchiveObjectWithData(data) as? NSNetService
        }
        return netService
    }
}

@objc public class NSArrayToNSStringTransformer: NSValueTransformer {
    
    public override class func transformedValueClass() -> AnyClass { return NSString.self }
    
    public override func transformedValue(value: AnyObject?) -> AnyObject? {
        var string: NSString? = nil
        if let peers = value as? NSArray {
            string = peers.componentsJoinedByString(",")
        }
        return string
    }
}

//@objc public class NSSetToNSStringTransformer: NSValueTransformer {
//    
//    public override class func transformedValueClass() -> AnyClass { return NSString.self }
//    
//    public override func transformedValue(value: AnyObject?) -> AnyObject? {
//        var string: NSString? = nil
//        if let peers: NSArray = (value as? NSSet)?.allObjects {
//            string = peers.componentsJoinedByString(",")
//        }
//        return string
//    }
//}
