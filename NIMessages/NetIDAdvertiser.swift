//
//  NetIDAdvertiser.swift
//  NIMessagesSimple
//
//  Created by Abhishek Munie on 07/10/14.
//  Copyright (c) 2014 Abhishek Munie. All rights reserved.
//

//import CoreFoundation
import Cocoa

@objc public class NetIDAdvertiser: NSObject, NSNetServiceDelegate {

    public var netID: NetID
    public var discoveryInfo: [NSObject : AnyObject]!
    public var serviceType: String
    
    var certificate: SecCertificate?
    var publicKey: SecKey?
    var privateKey: SecKey?
    
    public let netService: NSNetService
    
    init(netID myNetID: NetID, discoveryInfo info: [NSObject : AnyObject]!, serviceType: String) {
        self.netID = myNetID
        self.discoveryInfo = info
        self.serviceType = serviceType
        
        self.netService = NSNetService(domain: "",
            type: serviceType,
            name: myNetID.identifier,
            port: 0)
        
        super.init()
        
        self.netService.setTXTRecordData(NSNetService.dataFromTXTRecordDictionary(discoveryInfo))
        self.netService.includesPeerToPeer = true
        self.netService.delegate = self
    }
    
    // The methods -startAdvertisingPeer and -stopAdvertisingPeer are used to start and stop announcing presence to nearby browsing peers.
    func start() {
        self.netService.publishWithOptions(NSNetServiceOptions.ListenForConnections)
    }
    
    func stop() {
        self.netService.stop()
    }
    
    weak var delegate: NetIDAdvertiserDelegate?


    // MARK: - NSNetServiceDelegate

    /* Sent to the NSNetService instance's delegate prior to advertising the service on the network. If for some reason the service cannot be published, the delegate will not receive this message, and an error will be delivered to the delegate via the delegate's -netService:didNotPublish: method.
    */
    public func netServiceWillPublish(sender: NSNetService) {
        assert(sender === self.netService)
        
    }
    
    /* Sent to the NSNetService instance's delegate when the publication of the instance is complete and successful.
    */
    public func netServiceDidPublish(sender: NSNetService) {
        assert(sender === self.netService)
        self.delegate?.advertiserDidStartAdvertising?(self)
    }
    
    /* Sent to the NSNetService instance's delegate when an error in publishing the instance occurs. The error dictionary will contain two key/value pairs representing the error domain and code (see the NSNetServicesError enumeration above for error code constants). It is possible for an error to occur after a successful publication.
    */
    public func netService(sender: NSNetService, didNotPublish errorDict: [NSObject : AnyObject]) {
        assert(sender === self.netService)
        self.delegate?.advertiser?(self, didNotStartAdvertising: errorDict)
    }
    
    /* Sent to the NSNetService instance's delegate when the instance's previously running publication or resolution request has stopped.
    */
    public func netServiceDidStop(sender: NSNetService) {
        assert(sender === self.netService)
        
    }
    
    public func netService(sender: NSNetService, didAcceptConnectionWithInputStream inputStream: NSInputStream, outputStream: NSOutputStream) {
        self.delegate?.advertiser?(self, didAcceptConnectionWithInputStream: inputStream, outputStream: outputStream)
    }
}

@objc protocol NetIDAdvertiserDelegate {
    
    optional func advertiserDidStartAdvertising(advertiser: NetIDAdvertiser)
    
    // Advertising did not start due to an error
    optional func advertiser(advertiser: NetIDAdvertiser, didNotStartAdvertising errorDict: [NSObject : AnyObject])
    
    optional func advertiser(advertiser: NetIDAdvertiser, didAcceptConnectionWithInputStream inputStream: NSInputStream, outputStream: NSOutputStream)
    
//    optional func advertiser(advertiser: NetIDAdvertiser, didAcceptConnectionWithInputStream inputStream: NSInputStream, outputStream: NSOutputStream, from netID: NetID, withNetService sender: NSNetService)
    
//    optional func advertiser(advertiser: NetIDAdvertiser, verifiedPeerForAcceptConnectionWithInputStream inputStream: NSInputStream, outputStream: NSOutputStream) -> NetID?
}
