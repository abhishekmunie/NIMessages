//
//  NetIDHandler.swift
//  NIMessages
//
//  Created by Abhishek Munie on 25/10/14.
//  Copyright (c) 2014 Abhishek Munie. All rights reserved.
//

import Cocoa

@objc public class NetIDHandler: NSObject, NetIDAdvertiserDelegate, NetIDBrowserDelegate, NetIDBrowserStore, SessionDelegate, SessionDataStore, ConnectionStore {
    
    let advertiser: NetIDAdvertiser
    let browser: NetIDBrowser
    
    public weak var delegate: NetIDHandlerDelegate?
    
    public var encryptionPreference: Connection.EncryptionPreference = .Required
    
    private var netIDs = [String: NetID]()
    private var sessions = [NetID: [NSNetService: Session]]()
    
    let pendingNetIDToAdd = NSMutableSet()
    let pendingNetIDToRemove = NSMutableSet()
    
    public init(netID myNetID: NetID, discoveryInfo info: [NSObject : AnyObject]!, serviceType: String, inRunLoop runLoop: NSRunLoop = NSRunLoop.currentRunLoop()) {
        self.advertiser = NetIDAdvertiser(netID: myNetID, discoveryInfo: info, serviceType: serviceType)
        self.browser = NetIDBrowser(serviceType: serviceType, domain: "", inRunLoop: runLoop)
        
        super.init()
        
        self.advertiser.delegate = self
        
        self.browser.excludedIdentifiers[myNetID.identifier] = true
        self.browser.delegate = self
        self.browser.netIDStore = self
    }
    
    public func start() {
        self.advertiser.start()
        self.browser.start()
    }
    
    public func stop() {
        self.advertiser.stop()
        self.browser.stop()
    }
    
    public func sendData(data: NSData,
        toPeers peerNetID: NetID,
        withMode mode: Session.SendDataMode,
        error: NSErrorPointer) -> Bool {
            if let sessionsForNetID = self.sessions[peerNetID] {
                var success = true
                for (netService, session) in sessionsForNetID {
                    let s = session.sendData(data,
                        withMode: mode,
                        error: error)
                    success = success && s
                }
                return success
            } else {
                error.memory = NSError(domain: MyErrorDomain,
                    code: 2435,
                    userInfo: [NSLocalizedDescriptionKey : "Peer not avaliable \(peerNetID.name)<\(peerNetID.identity)>"])
                return false
            }
    }
    
    public func sendData(data: NSData,
        toPeersWithIdentity peerIdentityString: String,
        withMode mode: Session.SendDataMode,
        error: NSErrorPointer) -> Bool {
            if let peerNetID = self.netIDs[peerIdentityString] {
                return self.sendData(data,
                    toPeers: peerNetID,
                    withMode: mode,
                    error: error)
            } else {
                error.memory = NSError(domain: MyErrorDomain,
                    code: 2435,
                    userInfo: [NSLocalizedDescriptionKey : "Peer not avaliable <\(peerIdentityString)>"])
                return false
            }
    }
    
    // MARK - NetIDAdvertiserDelegate
    
    func advertiserDidStartAdvertising(advertiser: NetIDAdvertiser) {
        
    }
    
    func advertiser(advertiser: NetIDAdvertiser, didNotStartAdvertising error: NSError?) {
        
    }
    
    private var unrecognizedConnections = NSMutableSet()
    
    func advertiser(advertiser: NetIDAdvertiser,
        didAcceptConnectionWithInputStream inputStream: NSInputStream,
        outputStream: NSOutputStream) {
            println("Did Accept Connection.")
            var newConnection = Connection(
                inputStream: inputStream,
                outputStream: outputStream,
                encryptionPreference: self.encryptionPreference
            )
            newConnection.acceptsInbound = true
            newConnection.store = self
            newConnection.start()
            self.unrecognizedConnections.addObject(newConnection)
    }
    
//    func advertiser(advertiser: NetIDAdvertiser,
//        verifiedPeerForAcceptConnectionWithInputStream inputStream: NSInputStream,
//        outputStream: NSOutputStream) -> NetID? {
//            
//    }

    
    // MARK - NetIDBrowserDelegate
    
    public func netIDBrowser(aNetIDBrowser: NetIDBrowser, didFindPeer aPeerNetID: NetID, moreComing: Bool) {
        self.delegate?.netIDHandler?(self, didFindPeer: aPeerNetID, moreComing: moreComing)
    }
    
    public func netIDBrowser(aNetIDBrowser: NetIDBrowser, didRemovePeer aPeerNetID: NetID, moreComing: Bool) {
        self.delegate?.netIDHandler?(self, didRemovePeer: aPeerNetID, moreComing: moreComing)
    }
    
    // MARK - NetIDBrowserStore
    
    func netIDBrowser(aNetIDBrowser: NetIDBrowser, didFindService aNetService: NSNetService, moreComing: Bool) {
        if let identity = NetID.identityFromIdentifier(aNetService.name) {
            if let netID = self.netIDs[identity] {
                let newSession = Session(netService: aNetService)
                newSession.encryptionPreference = self.encryptionPreference
                newSession.representedNetService = self.advertiser.netService
                newSession.delegate = self
                newSession.dataStore = self
                self.sessions[netID]![aNetService] = newSession
                return
            } else {
                if let aNewNetID = NetID(peerNetService: aNetService) {
                    let newSession = Session(netService: aNetService)
                    newSession.encryptionPreference = self.encryptionPreference
                    newSession.representedNetService = self.advertiser.netService
                    newSession.delegate = self
                    newSession.dataStore = self
                    self.netIDs[aNewNetID.identity] = aNewNetID
                    self.sessions[aNewNetID] = [aNetService: newSession]
                    // TODO: - Update to correctly handle moreComing
                    self.browser.netIDBrowserStore(self, didFindPeer: aNewNetID, moreComing: false)
                }
            }
        }
    }
    
    func netIDBrowser(aNetIDBrowser: NetIDBrowser, didRemoveService aNetService: NSNetService, moreComing: Bool) {
        if let identity = NetID.identityFromIdentifier(aNetService.name) {
            if let netID = self.netIDs[identity] {
                if let lostSession = self.sessions[netID]![aNetService] {
                    lostSession.delegate = nil
                    lostSession.dataStore = nil
                    self.sessions[netID]![aNetService] = nil
                    if self.sessions[netID]!.count == 0 {
                        self.sessions[netID] = nil
                        self.netIDs[netID.identity] = nil
                        // TODO: - Update to correctly handle moreComing
                        self.browser.netIDBrowserStore(self, didRemovePeer: netID, moreComing: false)
                    }
                }
            } else {
            }
        }
    }
    
    
    // MARK: - SessionDelegate
    
    public func session(session: Session, didSendData data: NSData) {
        if let identity = NetID.identityFromIdentifier(session.netService.name) {
            if let peerNetID = self.netIDs[identity] {
                self.delegate?.netIDHandler?(self, didSendData: data, toPeer: peerNetID)
            }
        }
    }
    
    public func session(session: Session, didReceiveData data: NSData) {
        if let identity = NetID.identityFromIdentifier(session.netService.name) {
            if let peerNetID = self.netIDs[identity] {
                self.delegate?.netIDHandler?(self, didReceiveData: data, fromPeer: peerNetID)
            }
        }
    }
    
    // MARK: - ConnectionStore
    
    func connection(connection: Connection,
        didReceiveFromValidatedNetID aPeerNetID: NetID,
        withNetService aNetService: NSNetService) {
            println("Did Accept Validated Connection from \(aPeerNetID)")
//            if let netID = self.netIDs[aPeerNetID.identity] {
                if let session = self.sessions[aPeerNetID]?[aNetService] {
                    connection.representedNetService = aNetService
                    session.receiveDataFromConnection(connection)
                    self.unrecognizedConnections.removeObject(connection)
                }
//            } else {
//                
//            }
    }
    
}

@objc public protocol NetIDHandlerDelegate: NSObjectProtocol {
    
    optional func netIDHandler(aNetIDHandler: NetIDHandler, didFindPeer aPeerNetID: NetID, moreComing: Bool)
    
    optional func netIDHandler(aNetIDHandler: NetIDHandler, didRemovePeer aPeerNetID: NetID, moreComing: Bool)
    
    optional func netIDHandler(aNetIDHandler: NetIDHandler, didSendData data: NSData, toPeer aPeerNetID: NetID)
    
    optional func netIDHandler(aNetIDHandler: NetIDHandler, didReceiveData data: NSData, fromPeer aPeerNetID: NetID)
}
