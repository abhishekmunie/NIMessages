//
//  NetIDBrowser.swift
//  NIMessagesSimple
//
//  Created by Abhishek Munie on 09/10/14.
//  Copyright (c) 2014 Abhishek Munie. All rights reserved.
//

import Cocoa

@objc public class NetIDBrowser: NSObject, NSNetServiceBrowserDelegate, NetServiceDomainBrowserDelegate, NetIDBrowserStoreDelegate {
    
    public let serviceType: String
    public let domain: String?
    let runLoop: NSRunLoop
    
    enum State {
        case Stopped, Starting, Started, Stopping
    }
    private var state: State = .Stopped
    
    weak var netIDStore: NetIDBrowserStore?
    weak var delegate: NetIDBrowserDelegate?
    
    private var domainBrowser: NSNetServiceBrowser?
    private var netServiceBrowsers = [String: NetServiceDomainBrowser]()
    
    public var excludedIdentifiers = [String: Bool]()
    
    public init(serviceType: String, domain domainString: String?, inRunLoop runLoop: NSRunLoop = NSRunLoop.currentRunLoop()) {
        self.serviceType = serviceType
        self.domain = domainString
        self.runLoop = runLoop
        
        super.init()
        
        if let restrictedToDomain = domainString {
        } else {
            let domainBrowser = NSNetServiceBrowser()
            domainBrowser.delegate = self
            domainBrowser.includesPeerToPeer = true
            self.domainBrowser = domainBrowser
//            self.startBrowserInDomain("")
        }
    }
    
    public func start() {
        self.state = .Starting
        if let restrictedToDomain = self.domain {
            self.startBrowsingInDomain(restrictedToDomain)
        } else {
            self.domainBrowser?.scheduleInRunLoop(self.runLoop, forMode: NSDefaultRunLoopMode)
            self.domainBrowser?.searchForBrowsableDomains()
        }
    }
    
    public func stop() {
        self.state = .Stopping
        if let restrictedToDomain = self.domain {
            self.stopBrowsingInDomain(restrictedToDomain)
        } else {
            self.domainBrowser?.stop()
        }
    }
    
    private func startBrowsingInDomain(domainString: String) {
        let browser = NetServiceDomainBrowser(serviceType: self.serviceType, domain: domainString, inRunLoop: self.runLoop)
        browser.delegate = self
        self.netServiceBrowsers[domainString] = browser
    }
    
    private func stopBrowsingInDomain(domainString: String) {
        if let browser = netServiceBrowsers[domainString] {
            browser.stop()
        }
    }
    
    /* Sent to the NSNetServiceBrowser instance's delegate before the instance begins a search. The delegate will not receive this message if the instance is unable to begin a search. Instead, the delegate will receive the -netServiceBrowser:didNotSearch: message.
    */
    public func netServiceBrowserWillSearch(aNetServiceBrowser: NSNetServiceBrowser) {
        
    }
    
    /* Sent to the NSNetServiceBrowser instance's delegate when the instance's previous running search request has stopped.
    */
    public func netServiceBrowserDidStopSearch(aNetServiceBrowser: NSNetServiceBrowser) {
        if let domainBrowser = self.domainBrowser {
            if aNetServiceBrowser === domainBrowser {
                domainBrowser.removeFromRunLoop(self.runLoop, forMode: NSDefaultRunLoopMode)
                domainBrowser.delegate = nil
                self.domainBrowser = nil
            }
        }
    }
    
    /* Sent to the NSNetServiceBrowser instance's delegate when an error in searching for domains or services has occurred. The error dictionary will contain two key/value pairs representing the error domain and code (see the NSNetServicesError enumeration above for error code constants). It is possible for an error to occur after a search has been started successfully.
    */
    public func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didNotSearch errorDict: [NSObject : AnyObject]) {
//        var errorCode = errorDict[NSNetServicesErrorCode]
//        var error = errorDict[NSNetServicesErrorDomain]
//        browser.removeFromRunLoop(self.runLoop, forMode: NSDefaultRunLoopMode)
//        browser.delegate = nil
//        self.netServiceBrowsers[domainString] = nil
    }
    
    /* Sent to the NSNetServiceBrowser instance's delegate for each domain discovered. If there are more domains, moreComing will be YES. If for some reason handling discovered domains requires significant processing, accumulating domains until moreComing is NO and then doing the processing in bulk fashion may be desirable.
    */
    public func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didFindDomain domainString: String, moreComing: Bool) {
        self.stopBrowsingInDomain(domainString)
    }
    
    /* Sent to the NSNetServiceBrowser instance's delegate when a previously discovered domain is no longer available.
    */
    public func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didRemoveDomain domainString: String, moreComing: Bool) {
        self.stopBrowsingInDomain(domainString)
    }
    
    
    // MARK - NetServiceDomainBrowserDelegate
    
    private func netServiceDomainBrowserWillSearch(aNetServiceDomainBrowser: NetServiceDomainBrowser) {
    }
    
    private func netServiceDomainBrowserDidStopSearch(aNetServiceDomainBrowser: NetServiceDomainBrowser) {
//        self.netServiceBrowsers[aNetServiceDomainBrowser.domain] = nil
        
    }
    
    private func netServiceDomainBrowser(aNetServiceDomainBrowser: NetServiceDomainBrowser, didNotSearch errorDict: [NSObject : AnyObject]) {
        
    }
    
    private func netServiceDomainBrowser(aNetServiceDomainBrowser: NetServiceDomainBrowser, didFindService aNetService: NSNetService, moreComing: Bool) {
        let identifier = aNetService.name
        if self.excludedIdentifiers[identifier] == nil {
            println("Found NSNetService: \(aNetService.name)")
            self.netIDStore?.netIDBrowser?(self, didFindService: aNetService, moreComing: moreComing)
        }
    }
    
    private func netServiceDomainBrowser(aNetServiceDomainBrowser: NetServiceDomainBrowser, didRemoveService aNetService: NSNetService, moreComing: Bool) {
        let identifier = aNetService.name
        if self.excludedIdentifiers[identifier] == nil {
            println("Lost NSNetService: \(aNetService.name)")
            self.netIDStore?.netIDBrowser?(self, didRemoveService: aNetService, moreComing: moreComing)
        }
    }
    
    
    // MARK - NetIDBrowserStoreDelegate
    
    func netIDBrowserStore(aNetIDBrowserStore: NetIDBrowserStore, didFindPeer aPeerNetID: NetID, moreComing: Bool) {
        self.delegate?.netIDBrowser?(self, didFindPeer: aPeerNetID, moreComing: moreComing)
    }
    
    func netIDBrowserStore(aNetIDBrowserStore: NetIDBrowserStore, didRemovePeer aPeerNetID: NetID, moreComing: Bool) {
        self.delegate?.netIDBrowser?(self, didRemovePeer: aPeerNetID, moreComing: moreComing)
    }
    
}

@objc protocol NetIDBrowserStore: NSObjectProtocol {
    
    optional func netIDBrowser(aNetIDBrowser: NetIDBrowser, didFindService aNetService: NSNetService, moreComing: Bool)
    
    optional func netIDBrowser(aNetIDBrowser: NetIDBrowser, didRemoveService aNetService: NSNetService, moreComing: Bool)
}

@objc protocol NetIDBrowserStoreDelegate: NSObjectProtocol {
    
    optional func netIDBrowserStore(aNetIDBrowserStore: NetIDBrowserStore, didFindPeer aPeerNetID: NetID, moreComing: Bool)
    
    optional func netIDBrowserStore(aNetIDBrowserStore: NetIDBrowserStore, didRemovePeer aPeerNetID: NetID, moreComing: Bool)
}

@objc public protocol NetIDBrowserDelegate: NSObjectProtocol {
    
    optional func netIDBrowser(aNetIDBrowser: NetIDBrowser, didFindPeer aPeerNetID: NetID, moreComing: Bool)
    
    optional func netIDBrowser(aNetIDBrowser: NetIDBrowser, didRemovePeer aPeerNetID: NetID, moreComing: Bool)
}

@objc private class NetServiceDomainBrowser: NSObject, NSNetServiceBrowserDelegate {
    
    let domain: String
    let serviceType: String
    var runLoop: NSRunLoop
    let browser: NSNetServiceBrowser
    
    weak var delegate: NetServiceDomainBrowserDelegate?
    
//    var avaliableServices = [String: NSNetService]()
    
    init(serviceType: String, domain domainString: String, inRunLoop runLoop: NSRunLoop) {
        self.serviceType = serviceType
        self.domain = domainString
        self.runLoop = runLoop
        self.browser = NSNetServiceBrowser()
        
        super.init()
        
        self.browser.delegate = self
        self.browser.includesPeerToPeer = true
        self.browser.scheduleInRunLoop(runLoop, forMode: NSDefaultRunLoopMode)
        self.browser.searchForServicesOfType(serviceType, inDomain: domainString)
    }
    
    func stop() {
        self.browser.stop()
    }
    
    deinit {
//        self.stop()
    }
    
    /* Sent to the NSNetServiceBrowser instance's delegate before the instance begins a search. The delegate will not receive this message if the instance is unable to begin a search. Instead, the delegate will receive the -netServiceBrowser:didNotSearch: message.
    */
    func netServiceBrowserWillSearch(aNetServiceBrowser: NSNetServiceBrowser) {
        self.delegate?.netServiceDomainBrowserWillSearch?(self)
    }
    
    /* Sent to the NSNetServiceBrowser instance's delegate when the instance's previous running search request has stopped.
    */
    func netServiceBrowserDidStopSearch(aNetServiceBrowser: NSNetServiceBrowser) {
        self.browser.removeFromRunLoop(self.runLoop, forMode: NSDefaultRunLoopMode)
        self.browser.delegate = nil
        self.delegate?.netServiceDomainBrowserDidStopSearch?(self)
    }
    
    /* Sent to the NSNetServiceBrowser instance's delegate when an error in searching for domains or services has occurred. The error dictionary will contain two key/value pairs representing the error domain and code (see the NSNetServicesError enumeration above for error code constants). It is possible for an error to occur after a search has been started successfully.
    */
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didNotSearch errorDict: [NSObject : AnyObject]) {
        self.browser.removeFromRunLoop(self.runLoop, forMode: NSDefaultRunLoopMode)
//        self.browser.delegate = nil
        self.delegate?.netServiceDomainBrowser?(self, didNotSearch: errorDict)
    }
    
    /* Sent to the NSNetServiceBrowser instance's delegate for each service discovered. If there are more services, moreComing will be YES. If for some reason handling discovered services requires significant processing, accumulating services until moreComing is NO and then doing the processing in bulk fashion may be desirable.
    */
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didFindService aNetService: NSNetService, moreComing: Bool) {
//        self.avaliableServices[aNetService.name] = aNetService
        self.delegate?.netServiceDomainBrowser?(self, didFindService: aNetService, moreComing: moreComing)
    }
    
    /* Sent to the NSNetServiceBrowser instance's delegate when a previously discovered service is no longer published.
    */
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didRemoveService aNetService: NSNetService, moreComing: Bool) {
//        self.avaliableServices[aNetService.name] = nil
        self.delegate?.netServiceDomainBrowser?(self, didRemoveService: aNetService, moreComing: moreComing)
    }
}

@objc private protocol NetServiceDomainBrowserDelegate: NSObjectProtocol {
    
    optional func netServiceDomainBrowserWillSearch(aNetServiceDomainBrowser: NetServiceDomainBrowser)
    
    optional func netServiceDomainBrowserDidStopSearch(aNetServiceDomainBrowser: NetServiceDomainBrowser)
    
    optional func netServiceDomainBrowser(aNetServiceDomainBrowser: NetServiceDomainBrowser, didNotSearch errorDict: [NSObject : AnyObject])
    
    optional func netServiceDomainBrowser(aNetServiceDomainBrowser: NetServiceDomainBrowser, didFindService aNetService: NSNetService, moreComing: Bool)
    
    optional func netServiceDomainBrowser(aNetServiceDomainBrowser: NetServiceDomainBrowser, didRemoveService aNetService: NSNetService, moreComing: Bool)
}
