//
//  AppNetIDHandlerDelegate.swift
//  NIMessages
//
//  Created by Abhishek Munie on 29/10/14.
//  Copyright (c) 2014 Abhishek Munie. All rights reserved.
//

import Cocoa

class AppNetIDHandlerDelegate: NSObject, NetIDHandlerDelegate {

    
    func netIDHandler(aNetIDHandler: NetIDHandler, didFindPeer aPeerNetID: NetID, moreComing: Bool) {
        println("Found Peer: \(aPeerNetID.name)<\(aPeerNetID.identity)>")
        let newPeer = Peer.peerWithNetID(aPeerNetID, inManagedObjectContext: ManagedObjectContext)
        newPeer.available = true
        
        newPeer.conversation.createSampleMessages(100)
        
        newPeer.conversation.available = true
    }
    
    func netIDHandler(aNetIDHandler: NetIDHandler, didRemovePeer aPeerNetID: NetID, moreComing: Bool) {
        println("Lost Peer: \(aPeerNetID.name)<\(aPeerNetID.identity)>")
        let lostPeer = Peer.peerWithNetID(aPeerNetID, inManagedObjectContext: ManagedObjectContext)
        lostPeer.available = false
        lostPeer.conversation.available = false
    }
    
    func netIDHandler(aNetIDHandler: NetIDHandler, didSendData data: NSData, toPeer aPeerNetID: NetID) {
        
    }
    
    func netIDHandler(aNetIDHandler: NetIDHandler, didReceiveData data: NSData, fromPeer aPeerNetID: NetID) {
        let msgText = NSString(data: data, encoding: NSUTF8StringEncoding)!
        let peer = Peer.peerWithNetID(aPeerNetID,
            inManagedObjectContext: ManagedObjectContext)
        let message = Message.messageWithText(msgText,
                    date: NSDate(),
                    sender: peer,
                    conversation: peer.conversation,
                    inManagedObjectContext: ManagedObjectContext)
    }
    
}
