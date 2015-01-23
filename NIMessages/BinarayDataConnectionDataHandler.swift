//
//  BinarayDataConnectionDataHandler.swift
//  NIMessages
//
//  Created by Abhishek Munie on 22/10/14.
//  Copyright (c) 2014 Abhishek Munie. All rights reserved.
//

import Cocoa

private let _DataType: String = "b"

@objc public class FixedLengthInbondBinaryDataConnectionHandler: FixedLengthInbondDataConnectionHandler {
    
    public class var dataType: String { return _DataType }
    
    struct Config {
        static let MaxBlockSize: Int = 1024
    }
    
    let inboundDataLength: Int
    var inboundData: NSMutableData
    
    public let dataAttributes: Connection.DataAttributes
    public var receivedData: NSData { return self.inboundData as NSData }
    public dynamic var progress: Float = 0.0
    
    private init(dataAttributes: Connection.DataAttributes,
        inboundDataLength: Int) {
            self.dataAttributes = dataAttributes
            self.inboundDataLength = inboundDataLength
            self.inboundData = NSMutableData(capacity: inboundDataLength)!
    }
    
    init?(dataAttributes: Connection.DataAttributes) {
        if let inboundDataLength = dataAttributes[Connection.DataAttributeKey.Length.rawValue]?.toInt()? {
            self.dataAttributes = dataAttributes
            self.inboundDataLength = inboundDataLength
            self.inboundData = NSMutableData(capacity: inboundDataLength)!
        } else {
            self.dataAttributes = [:]
            self.inboundDataLength = 0
            self.inboundData = NSMutableData(capacity: 0)!
            return nil
        }
    }
    
    private func updateProgress() { self.progress = Float(self.inboundData.length) / Float(self.inboundDataLength) }
    
    public func connection(connection: Connection, hasBytesAvailableInInputStream inputStream: NSInputStream) -> Float {
        let totalLengthToBeRead = self.inboundDataLength - self.inboundData.length
        let lengthToBeRead = min(totalLengthToBeRead, Config.MaxBlockSize)
//        let lengthToBeRead = Config.MaxBlockSize
        var buf = UnsafeMutablePointer<UInt8>.alloc(lengthToBeRead)
        let lenRead = inputStream.read(buf, maxLength: lengthToBeRead)
        if lenRead != 0 {
            self.inboundData.appendBytes(buf, length: lenRead)
            self.updateProgress()
        } else {
            println("no input data!")
//            return -1.0
        }
        return self.progress
    }
}

@objc public class FixedLengthOutbondBinaryDataConnectionHandler: FixedLengthOutbondDataConnectionHandler {
    
    public class var dataType: String { return _DataType }
    
    struct Config {
        static let MaxBlockSize: Int = 1024
    }
    
    let outboundDataLength: Int
    public let outboundData: NSData
    var outDataPointer: UnsafePointer<UInt8>
    
    public let dataAttributes: Connection.DataAttributes
    public dynamic var progress: Float = 0.0
    
    init(dataAttributes: Connection.DataAttributes,
        outboundData: NSData) {
        self.dataAttributes = dataAttributes
        self.outboundData = outboundData
        self.outboundDataLength = outboundData.length
        self.dataAttributes[Connection.DataAttributeKey.Length.rawValue] = "\(self.outboundDataLength)"
        self.outDataPointer = UnsafePointer<UInt8>(self.outboundData.bytes)
    }
    
    private func updateProgress() { self.progress = Float(self.outboundData.length) / Float(self.outboundDataLength) }
    
    public func connection(connection: Connection, hasSpaceAvailableInOutputStream outputStream: NSOutputStream) -> Float {
        let totalLengthToBeWritten = self.outboundDataLength - self.outboundData.bytes.distanceTo(self.outDataPointer)
        let lengthToBeWritten = min(totalLengthToBeWritten, Config.MaxBlockSize)
        let writenLen = outputStream.write(self.outDataPointer, maxLength: lengthToBeWritten)
        if writenLen > 0 {
            self.outDataPointer = self.outDataPointer.advancedBy(writenLen)
            self.updateProgress()
        } else {
            println("no data written!")
            //            return -1.0
        }
        return self.progress
    }
}
