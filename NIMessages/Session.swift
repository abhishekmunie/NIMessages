//
//  Session.swift
//  NIMessagesSimple
//
//  Created by Abhishek Munie on 30/09/14.
//  Copyright (c) 2014 Abhishek Munie. All rights reserved.
//

import Cocoa

@objc public class Session: NSObject, NSNetServiceDelegate, ConnectionDelegate {
    
    //    var peer: Peer
    var netService: NSNetService
    var encryptionPreference: Connection.EncryptionPreference
    
    public var representedNetService: NSNetService?
    
    enum State : Int {
        
        case NotConnected // not in the connection
        case Connecting   // connecting to this peer
        case Connected    // connected to the connection
    }
    
    public enum SendDataMode : Int {
        
        case Reliable   // guaranteed reliable and in-order delivery
        case Unreliable // sent immediately without queuing, no guaranteed delivery
    }
    
    
    public weak var delegate: SessionDelegate?
    public weak var dataStore: SessionDataStore?
    
    private var connections = NSMutableOrderedSet()
    //    private var freeConnections = NSMutableOrderedSet()
    
    init(netService: NSNetService, encryptionPreference: Connection.EncryptionPreference = .Optional) {
        //        let identity = netService.name
        //        self.peer = Peer.peerWithIdentity(identity,
        //            inManagedObjectContext: ManagedObjectContext)
        println("Session Created for \(netService.name)")
        self.netService = netService
        self.encryptionPreference = encryptionPreference
        
        super.init()
        
        //        self.netService.delegate = self
        //        self.netService.startMonitoring()
    }
    
    private func createConnectionWithInputStream(inputStream: NSInputStream, outputStream: NSOutputStream) -> Connection {
        var newConnection = Connection(
            inputStream: inputStream,
            outputStream: outputStream,
            encryptionPreference: self.encryptionPreference
        )
        newConnection.delegate = self
        newConnection.isServer = kCFBooleanTrue
        newConnection.representedNetService = self.representedNetService
        self.connections.addObject(newConnection)
        //        self.freeConnections.addObject(newConnection)
        return newConnection
    }
    
    private func createConnection() -> Connection? {
        var ins: NSInputStream?
        var outs: NSOutputStream?
        var retrivedSuccessfully = self.netService.getInputStream(&ins, outputStream:&outs)
        if retrivedSuccessfully {
            if let inputStream = ins {
                if let outputStream = outs {
                    return createConnectionWithInputStream(inputStream, outputStream: outputStream)
                }
            }
        }
        return nil
    }
    
    //    private func usableConnection() -> Connection {
    //        var connection: Connection?
    //        connection = self.freeConnections.firstObject as? Connection
    //        if connection == nil {
    //            connection = self.createConnection()
    //        }
    //        self.freeConnections.removeObject(connection!)
    //        return connection!
    //    }
    private func usableConnection() -> Connection? {
        var connection: Connection?
        connection = self.createConnection()
        return connection
    }
    
    // Send a data message to a list of destination peers
    public func sendData(data: NSData,
        withMode mode: SendDataMode,
        error: NSErrorPointer) -> Bool {
            let dataAttr: Connection.DataAttributes = [
                Connection.DataAttributeKey.DataType.rawValue: FixedLengthOutbondBinaryDataConnectionHandler.dataType,
                Connection.DataAttributeKey.Length.rawValue: "\(data.length)"
            ]
            let outboundDataHandler = FixedLengthOutbondBinaryDataConnectionHandler(dataAttributes: dataAttr,
                outboundData: data)
            if let connection = self.usableConnection() {
                connection.outboundDataHandler = outboundDataHandler
                connection.start()
                return true
            } else {
                error.memory = NSError(domain: MyErrorDomain,
                    code: 7642,
                    userInfo: [NSLocalizedDescriptionKey : "Failed to connect to peer with identifier: \(netService.name)"])
                return false
            }
    }
    
    public func receiveDataFromConnection(connection: Connection) {
        connection.delegate = self
        self.connections.addObject(connection)
    }
    
    // MARK: - NSNetServiceDelegate
    
    /* Sent to the NSNetService instance's delegate when the instance is being monitored and the instance's TXT record has been updated. The new record is contained in the data parameter.
    */
    public func netService(sender: NSNetService, didUpdateTXTRecordData data: NSData) {
        
    }
    
    // MARK - ConnectionDelegate
    
    func connectionWillSendData(connection: Connection) {
        
    }
    
    func connectionDidSendData(connection: Connection) {
        if let outboundDataHandler = connection.outboundDataHandler {
            if let binaryDataHandler = outboundDataHandler as? FixedLengthOutbondBinaryDataConnectionHandler {
                let sentData = binaryDataHandler.outboundData
                self.delegate?.session?(self, didSendData: sentData)
            }
        }
    }
    
    func connection(connection: Connection, inboundDataHandlerforAttributes dataAttributes: Connection.DataAttributes) -> FixedLengthInbondDataConnectionHandler? {
        return FixedLengthInbondBinaryDataConnectionHandler(dataAttributes: dataAttributes)
    }
    
    func connectionWillReceiveData(connection: Connection) {
        
    }
    
    func connectionDidReceiveData(connection: Connection) {
        if let receivedData = connection.receivedData {
            self.delegate?.session?(self, didReceiveData: receivedData)
        }
    }
    
    func connection(connection: Connection, didEndWithError error: NSError?) {
        if let theError = error {
            NSLog("Error %li: %@", theError.code, theError.localizedDescription)
        }
        self.connections.removeObject(connection)
    }
}

@objc public protocol SessionDelegate {
    
    optional func session(session: Session, didSendData data: NSData)
    
    optional func session(session: Session, didReceiveData data: NSData)
    
}

@objc public protocol SessionDataStore {
    
    
    
}
