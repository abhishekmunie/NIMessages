//
//  Connection.swift
//  NIMessagesSimple
//
//  Created by Abhishek Munie on 24/09/14.
//  Copyright (c) 2014 Abhishek Munie. All rights reserved.
//

import Foundation

@objc public class Connection: NSObject, NSStreamDelegate {
    
    typealias HeaderLengthType = Int
    
    struct Config {
        static let MaxBlockSize: Int = 1024
        static let FileDataBufferLength: Int = 64
        static let HeaderLengthSize = sizeof(HeaderLengthType)
        static let UUIDLength = 11
    }
    
    public enum EncryptionPreference : Int {
        
        case Optional // session preferred encryption but will accept unencrypted connections
        case Required // session requires encryption
        case None     // session should not be encrypted
    }
    
    public typealias DataAttributes = [String: String]
    public enum DataAttributeKey: String {
        case Length = "l"
        case DataType = "t"
    }
    
    let inputStream: NSInputStream
    let outputStream: NSOutputStream
    public let encryptionPreference: EncryptionPreference
    
    public var representedNetService: NSNetService?
    
    var acceptsInbound: Bool = false
    var isServer: CFBoolean = kCFBooleanFalse
    
    weak var delegate: ConnectionDelegate?
    weak var store: ConnectionStore?
    
    var inboundDataHandler: FixedLengthInbondDataConnectionHandler?
    var outboundDataHandler: FixedLengthOutbondDataConnectionHandler? {
        didSet {
            if let odh = self.outboundDataHandler {
                self.outputHeader = encodeHeaderWithDataAttributes(odh.dataAttributes)
            }
        }
    }
    
    private var inputHeaderLength: HeaderLengthType = 0
    private var inputHeader: NSMutableData = NSMutableData()
    private var outputHeader: NSData = NSData()
    private var hasOutboundSpaceAvailable = false
    
    var receivedData: NSData? { return self.inboundDataHandler?.receivedData }
    
    private enum ChunkType { case ExtendedHandshake, New, Header, Body }
    private var currentInboundChunkType: ChunkType = .ExtendedHandshake
    private var currentOutboundChunkType: ChunkType = .ExtendedHandshake
    
    
    init(inputStream: NSInputStream,
        outputStream: NSOutputStream,
        encryptionPreference: EncryptionPreference) {
            self.inputStream = inputStream
            self.outputStream = outputStream
            self.encryptionPreference = encryptionPreference
            
            super.init()
            
            self.inputStream.delegate = self
            self.outputStream.delegate = self
    }
    
    func start() {
        if self.acceptsInbound {
            self.inputStream.am0_enableTLSWithCertificates([secIdentity], isServer: self.isServer)
            //        self.inputStream.setProperty(NSStreamNetworkServiceTypeVideo, forKey: NSStreamNetworkServiceType)
            self.inputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(),
                forMode:NSDefaultRunLoopMode)
            if self.inputStream.streamStatus == .NotOpen { self.inputStream.open() }
//            else { assertFailure("") }
        }
        if self.outboundDataHandler != nil {
            self.outputStream.am0_enableTLSWithCertificates([secIdentity], isServer: self.isServer)
            //        self.outputStream.setProperty(NSStreamNetworkServiceTypeVideo, forKey: NSStreamNetworkServiceType)
            self.outputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(),
                forMode:NSDefaultRunLoopMode)
            if self.outputStream.streamStatus == .NotOpen { self.outputStream.open() }
//            else { assertFailure("") }
        }
    }
    
    
    private func stopInputStream() {
        self.inputStream.close()
        self.inputStream.removeFromRunLoop(NSRunLoop.currentRunLoop(),
            forMode: NSDefaultRunLoopMode)
        self.inputStream.delegate = nil
    }
    
    private func stopOutputStream() {
        self.outputStream.close()
        self.outputStream.removeFromRunLoop(NSRunLoop.currentRunLoop(),
            forMode: NSDefaultRunLoopMode)
        self.outputStream.delegate = nil
    }
    
    private func stopWithError(error: NSError?) {
        self.stopInputStream()
        self.stopOutputStream()
        self.delegate?.connection?(self, didEndWithError: error)
    }
    
    private func encodeHeaderWithDataAttributes(dataAttributes: DataAttributes) -> NSData {
        return NSKeyedArchiver.archivedDataWithRootObject(dataAttributes as NSDictionary)
    }
    
    private func decodeHeaderWithData(data: NSData) -> DataAttributes? {
        if let unarchiveDictionary = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSDictionary {
            return (unarchiveDictionary as DataAttributes)
        }
        return nil
    }
    
    private func procecessHeader() {
        var header: Connection.DataAttributes?
        
        header = self.decodeHeaderWithData(self.inputHeader)
        
        if let dataAttr = header {
            println("Received Header: \(dataAttr)")
            if let inboundDataLength = dataAttr[DataAttributeKey.Length.rawValue]?.toInt() {
                self.inboundDataHandler = self.delegate?.connection(self, inboundDataHandlerforAttributes: dataAttr)
                if self.inboundDataHandler == nil {
                    if let type = dataAttr[DataAttributeKey.DataType.rawValue] {
                        switch type {
                        case FixedLengthInbondBinaryDataConnectionHandler.dataType:
                            self.inboundDataHandler = FixedLengthInbondBinaryDataConnectionHandler(dataAttributes: dataAttr)
                        default:
                            assertionFailure("Unimplemented data holder generator for Inbound Data Type: \(type)")
                        }
                    }
                }
                self.currentInboundChunkType = .Body
                
                self.delegate?.connectionWillReceiveData?(self)
                return
            }
        }
        println("Invalid Inbound Header Data \(self.inputHeader)")
        self.stopWithError(NSError(domain: MyErrorDomain,
            code: 8746,
            userInfo: [NSLocalizedDescriptionKey : "Invalid Inbound Header Data \(self.inputHeader)"]))
    }
    
    func processInputData() {
        println("Received Data: \(NSString(data: self.inboundDataHandler!.receivedData, encoding: NSUTF8StringEncoding))")
        self.delegate?.connectionDidReceiveData?(self)
        self.stopWithError(nil)
    }
    
    func updateInboudProgress() {
    }
    
    func processOutputData() {
        self.delegate?.connectionDidSendData?(self)
        self.stopWithError(nil)
    }
    
    func updateOutboudProgress() {
    }
    
    func processInboundExtendedHandshakeWithUUID(uuid: String) {
        if let certificate = self.inputStream.am0_getCertificate() {
            if let netID = NetID(certificate: certificate, uuid: uuid) {
                println("identiier: \(netID.identifier)")
                let netService = NSNetService(domain: "local.",
                    type: AM0NIMessagesNetServiceType,
                    name: netID.identifier)
                self.store?.connection?(self, didReceiveFromValidatedNetID: netID, withNetService: netService)
            }
        }
    }
    
    func stream(theStream: NSStream!, handleEvent streamEvent: NSStreamEvent) {
        if theStream == self.inputStream {
            let stream = self.inputStream
            switch (streamEvent) {
            case NSStreamEvent.OpenCompleted:
                println("Input: OpenCompleted")
                break
            case NSStreamEvent.HasBytesAvailable:
                switch self.currentInboundChunkType {
                case .ExtendedHandshake:
                    println("Input: HasBytesAvailable - ExtendedHandshake")
//                    println("RemoteHost: \(stream.am0_getPeerName())")
                    //                if validateSecTrustOfStream(theStream) {
                    //                    self.stop()
                    //                    return
                    //                }
                    var buf = UnsafeMutablePointer<UInt8>.alloc(Config.UUIDLength)
                    let lenRead = stream.read(buf, maxLength: Config.UUIDLength)
                    assert(lenRead == Config.UUIDLength, "lenRead disn't match UUIDLength")
                    if lenRead != 0 {
                        let uuidData = NSData(bytes: buf, length: Config.UUIDLength)
                        let uuid = NSString(data: uuidData, encoding: NSUTF8StringEncoding)!
                        self.processInboundExtendedHandshakeWithUUID(uuid)
                        self.currentInboundChunkType = .New
                    } else { println("no uuid data!") }
                case .New:
                    println("Input: HasBytesAvailable - New")
                    withUnsafeMutablePointer(&inputHeaderLength, { (inputHeaderLengthPtr) -> Int? in
                        return stream.read(unsafeBitCast(inputHeaderLengthPtr, UnsafeMutablePointer<UInt8>.self), maxLength: Config.HeaderLengthSize)
                    })
                    if self.inputHeaderLength > 0 {
                        self.inputHeader = NSMutableData(capacity: self.inputHeaderLength)!
                        self.currentInboundChunkType = .Header
                    } else {
                        self.stopWithError(NSError(domain: MyErrorDomain,
                            code: 8746,
                            userInfo: [NSLocalizedDescriptionKey : "Header Length cannot be: \(self.inputHeaderLength)"]))
                    }
                    println("Receiving Header of Length \(self.inputHeaderLength)")
                case .Header:
                    println("Input: HasBytesAvailable - Header")
                    let totalLengthToBeRead: Int = self.inputHeaderLength - self.inputHeader.length
                    var lengthToBeRead = min(totalLengthToBeRead, Config.MaxBlockSize)
                    var buf = UnsafeMutablePointer<UInt8>.alloc(lengthToBeRead)
                    let lenRead = stream.read(buf, maxLength: lengthToBeRead)
                    if lenRead != 0 {
                        self.inputHeader.appendBytes(buf, length:lenRead)
                    } else { println("no header data!") }
                    if self.inputHeaderLength == self.inputHeader.length {
                        self.procecessHeader()
                    }
                case .Body:
                    println("Input: HasBytesAvailable - Body")
                    let status = self.inboundDataHandler?.connection(self, hasBytesAvailableInInputStream: stream)
                    if 0.0 <= status && status < 1.0 {
                        self.updateInboudProgress()
                    } else if status == 1.0 {
                        self.processInputData()
                    } else if status == -1.0 {
                        self.stopWithError(nil)
                    } else {
                        println("Invalid Status!")
                    }
                }
            case NSStreamEvent.ErrorOccurred:
                println("Input: ErrorOccurred")
                let err = stream.streamError
                if let theError = err {
                    NSLog("Error %li: %@", theError.code, theError.localizedDescription)
                }
                self.stopWithError(err)
            case NSStreamEvent.EndEncountered:
                println("Input: EndEncountered")
                self.stopWithError(nil)
            default:
                println("Unhandled event code: \(streamEvent) for input stream: \(theStream)")
            }
        } else if theStream == self.outputStream {
            let stream = self.outputStream
            switch (streamEvent) {
            case NSStreamEvent.OpenCompleted:
                println("Output: OpenCompleted")
                break
            case NSStreamEvent.HasSpaceAvailable:
                println("Output: HasSpaceAvailable")
                self.hasOutboundSpaceAvailable = true
                self.send()
            case NSStreamEvent.ErrorOccurred:
                println("Output: ErrorOccurred")
                let err = stream.streamError
                if let theError = err {
                    NSLog("Error %li: %@", theError.code, theError.localizedDescription)
                }
                self.stopWithError(err)
            case NSStreamEvent.EndEncountered:
                println("Output: EndEncountered")
                self.stopWithError(nil)
            default:
                println("Unhandled event code: \(streamEvent) for output stream: \(theStream)")
            }
        }
    }
    
    private func send() {
        if self.hasOutboundSpaceAvailable {
            var writenLen: Int
            if let oHandler = self.outboundDataHandler {
                switch self.currentOutboundChunkType {
                case .ExtendedHandshake:
                    println("RemoteHost: \(self.outputStream.am0_getPeerName())")
                    //                if validateSecTrustOfStream(theStream) {
                    //                    self.stop()
                    //                    return
                    //                }
                    if let uuid = NetID.uuidFromIdentifier(self.representedNetService!.name) {
                        let uuidData = uuid.dataUsingEncoding(NSUTF8StringEncoding)!
                        let uuidPtr = UnsafePointer<UInt8>(uuidData.bytes)
                        writenLen = self.outputStream.write(uuidPtr, maxLength: Config.UUIDLength)
                        self.currentOutboundChunkType = .New
                        NSLog("UUID of Length %lu sent.", writenLen)
                    } else {
                        println("invalid uuid for send")
                        self.stopWithError(nil)
                    }
                case .New:
                    println("Output: Send - New")
                    self.delegate?.connectionWillSendData?(self)
                    var outboundHeaderLength = self.outputHeader.length
                    writenLen = withUnsafePointer(&outboundHeaderLength, { (lenPtr) -> Int in
                        return self.outputStream.write(unsafeBitCast(lenPtr, UnsafePointer<UInt8>.self), maxLength: Config.HeaderLengthSize)
                    })
                    self.currentOutboundChunkType = .Header
                case .Header:
                    println("Output: Send - Header")
                    writenLen = self.outputStream.write(UnsafePointer<UInt8>(self.outputHeader.bytes), maxLength: self.outputHeader.length)
                    self.currentOutboundChunkType = .Body
                    NSLog("Header of Length %lu sent.", writenLen)
                case .Body:
                    println("Output: Send - Body")
                    let status = oHandler.connection(self, hasSpaceAvailableInOutputStream: self.outputStream)
                    if 0.0 <= status && status < 1.0 {
                        self.updateOutboudProgress()
                    } else if status == 1.0 {
                        self.processOutputData()
                    } else if status == -1.0 {
                        self.stopWithError(nil)
                    } else {
                        println("Invalid Status!")
                    }
                }
                //                if writenLen >= 0 {
                self.hasOutboundSpaceAvailable = false
                //                } else {}
            }
        }
    }
    
}

public enum FixedLengthDataConnectionHandlerStatus: Int {
    case InProgress = 0, Completed, Error
}

@objc public protocol DataConnectionHandler {
    
    class var dataType: String { get }
    
    var dataAttributes: Connection.DataAttributes { get }
}

@objc public protocol FixedLengthDataConnectionHandler: DataConnectionHandler {
    
}

@objc public protocol FixedLengthInbondDataConnectionHandler: FixedLengthDataConnectionHandler {
    
    var receivedData: NSData { get }
    
    func connection(connection: Connection, hasBytesAvailableInInputStream: NSInputStream) -> Float
}

@objc public protocol FixedLengthOutbondDataConnectionHandler: FixedLengthDataConnectionHandler {
    
    func connection(connection: Connection, hasSpaceAvailableInOutputStream: NSOutputStream) -> Float
}

@objc protocol ConnectionStore: NSObjectProtocol {
    
    optional func connection(connection: Connection, didReceiveFromValidatedNetID aPeerNetID: NetID, withNetService aNetService: NSNetService)
}

@objc protocol ConnectionDelegate: NSObjectProtocol {
    
    func connection(connection: Connection, inboundDataHandlerforAttributes dataAttributes: Connection.DataAttributes) -> FixedLengthInbondDataConnectionHandler?
    
    optional func connectionWillSendData(connection: Connection)
    
    optional func connectionDidSendData(connection: Connection)
    
    optional func connectionWillReceiveData(connection: Connection)
    
    optional func connectionDidReceiveData(connection: Connection)
    
    optional func connection(connection: Connection, didEndWithError error: NSError?)
}
