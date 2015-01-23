import Foundation
import Security
import CoreServices
import XCPlayground

XCPSetExecutionShouldContinueIndefinitely()

//let SecImportExportPassphraseKey = kSecImportExportPassphrase!.takeUnretainedValue() as NSString
let SecImportExportPassphraseKey = "passphrase"
let SecOIDOrganizationNameKey: AnyObject?  = kSecOIDOrganizationName?.takeUnretainedValue()
let SecOIDX509V1SubjectNameKey = kSecOIDX509V1SubjectName?.takeUnretainedValue() as? NSString
let SecImportItemIdentityKey = kSecImportItemIdentity!.takeUnretainedValue() as NSString
let SecImportItemCertChainKey = kSecImportItemCertChain!.takeUnretainedValue() as NSString

let kAnchorAlreadyAdded: NSString = "AnchorAlreadyAdded"

let serviceType = "_am0nimsgpeer._tcp."

func importCertsWithResourceName(resourceName: String) -> [[String: AnyObject]]? {
    let mainBundle = NSBundle.mainBundle()
    if let p12FilePath = mainBundle.pathForResource(resourceName, ofType: "p12") {
        if let p12FileData = NSData(contentsOfFile: p12FilePath) {
            var certs: Unmanaged<CFArray>?
            let options: CFDictionary = [
                SecImportExportPassphraseKey: "test"
            ]
            let status = SecPKCS12Import(p12FileData, options, &certs)
            SecCopyErrorMessageString(status, nil).takeUnretainedValue()
            if status == noErr {
                if let res = certs?.takeUnretainedValue() as? [[String: AnyObject]] {
                    return res
                }
            } else if status == errSecItemNotFound {}
        }
    }
    return nil
}

func importCertificateWithResourceName(resourceName: String) -> SecCertificate? {
    let mainBundle = NSBundle.mainBundle()
    if let certificatePath = mainBundle.pathForResource(resourceName, ofType: "cer") {
        if let certificateData = NSData(contentsOfFile: certificatePath) {
            if let certificate = SecCertificateCreateWithData(nil, certificateData)?.takeUnretainedValue() {
                return certificate
            }
        }
    }
    return nil
}

func addAnchorToTrust(trust: SecTrust, trustedCert: SecCertificate) -> SecTrust {
    let newAnchorArray: CFArray = [trustedCert]
    
    SecTrustSetAnchorCertificates(trust, newAnchorArray)
    return trust
}

func changeHostForTrust(trust: SecTrust) -> SecTrust? {
    let sslPolicy = SecPolicyCreateSSL(1, "www.example.com").takeUnretainedValue()
    
    let newTrustPolicies = [sslPolicy] as CFArray
    
    var certificates: [SecCertificate] = []
    
    /* Copy the certificates from the original trust object */
    let count: CFIndex = SecTrustGetCertificateCount(trust)
    var i: CFIndex = 0
    for i = 0; i < count; i++ {
        let item = SecTrustGetCertificateAtIndex(trust, i).takeUnretainedValue()
        certificates.append(item)
    }
    
    /* Create a new trust object */
    var newtrust: Unmanaged<SecTrust>? = nil
    if (SecTrustCreateWithCertificates(certificates as CFArray, newTrustPolicies, &newtrust) != errSecSuccess) {
        /* Probably a good spot to log something. */
        
        return nil
    }
    
    return newtrust?.takeUnretainedValue()
}

func validateCertificateChain(certificateChain: [SecCertificate], forRootCertificate rootCertificate: SecCertificate, callback: (Bool) -> Void) -> OSStatus {
    let basicPolicy = SecPolicyCreateBasicX509().takeUnretainedValue()
    let policy = NSArray(object: basicPolicy)
    var trustR: Unmanaged<SecTrust>?
    SecTrustCreateWithCertificates(certificateChain, policy, &trustR)
    if let trust = trustR?.takeUnretainedValue() {
        SecTrustSetAnchorCertificates(trust, NSArray(object: rootCertificate))
        
        //        var resultPtr = UnsafeMutablePointer<SecTrustResultType>.alloc(1)
        let queue = dispatch_get_main_queue()
        return SecTrustEvaluateAsync(trust, queue) {
            (secTrust, secTrustResult) -> Void in
            let trustResult: Bool = secTrustResult == SecTrustResultType(kSecTrustResultUnspecified) || secTrustResult == SecTrustResultType(kSecTrustResultProceed)
            callback(trustResult)
        }
    }
    return -1
}

func validateSecTrustOfStream(theStream: NSStream) -> Bool {
    //    let certs: NSArray = theStream.propertyForKey(kCFStreamPropertySSLPeerCertificates as NSString)
    var trust = theStream.propertyForKey(kCFStreamPropertySSLPeerTrust) as SecTrust
    
    /* Because you don't want the array of certificates to keep
    growing, you should add the anchor to the trust list only
    upon the initial receipt of data (rather than every time).
    */
    let alreadyAdded = theStream.propertyForKey(kAnchorAlreadyAdded) as? Bool
    if alreadyAdded == nil || alreadyAdded! == false {
        trust = addAnchorToTrust(trust, rootCert) // defined earlier.
        theStream.setProperty((true as NSNumber), forKey: kAnchorAlreadyAdded)
    }
    var res: SecTrustResultType = SecTrustResultType(kSecTrustResultInvalid)
    
    if SecTrustEvaluate(trust, &res) != noErr {
        /* The trust evaluation failed for some reason.
        This probably means your certificate was broken
        in some way or your code is otherwise wrong. */
        
        //        /* Tear down the input stream. */
        //        [theStream removeFromRunLoop: ... forMode: ...];
        //        [theStream setDelegate: nil];
        //        [theStream close];
        //
        //        /* Tear down the output stream. */
        //        ...
        
        return false
        
    }
    
    if (res != SecTrustResultType(kSecTrustResultProceed) && res != SecTrustResultType(kSecTrustResultUnspecified)) {
        /* The host is not trusted. */
        //        /* Tear down the input stream. */
        //        [theStream removeFromRunLoop: ... forMode: ...];
        //        [theStream setDelegate: nil];
        //        [theStream close];
        //
        //        /* Tear down the output stream. */
        //        ...
        return false
    } else {
        // Host is trusted.  Handle the data callback normally.
        return true
    }
}

func addSecCert(certificate: SecCertificate) -> OSStatus {
    let attr: CFDictionary = [
        kSecClass as NSString: (kSecClassCertificate as AnyObject),
        kSecValueRef: certificate
    ]
    let err = SecItemAdd(attr, nil)
    //    (err == noErr) || (err == errSecDuplicateItem)
    return err
}



@objc public class NetID: NSObject, Hashable {
    
    var name: String
    var identity: String
    var uuid: String
    
    public override var hashValue: Int { return self.identity.hashValue }
    
    public init(name: String, identity: String) {
        self.name = name
        self.identity = identity
        
        let uuidRef = CFUUIDCreate(nil)
        let uuidStringRef = CFUUIDCreateString(nil, uuidRef)
        let str = uuidStringRef as String
        self.uuid = str[str.startIndex...advance(str.startIndex, 10, str.endIndex)]
    }
    
    private init(name: String, identity: String, uuid: String) {
        self.name = name
        self.identity = identity
        self.uuid = uuid
    }
    
    
    public var identifier: String {
        return "\(self.name)<\(self.identity)>(\(self.uuid))"
    }
    
    public override func isEqual(anObject: AnyObject?) -> Bool {
        if let obj: AnyObject = anObject {
            if let aNetID = obj as? NetID {
                return aNetID.identity == self.identity
            }
        }
        return false
    }
    
    public convenience init?(secIdentity: SecIdentity) {
        var commonName: Unmanaged<CFString>?
        var emailAddresses: Unmanaged<CFArray>?
        var certificate: Unmanaged<SecCertificate>?
        var err: Unmanaged<CFError>?
        SecIdentityCopyCertificate(secIdentity, &certificate)
        if let cert = certificate?.takeUnretainedValue() {
            SecCertificateCopyCommonName(cert, &commonName)
            let keys = [SecOIDX509V1SubjectNameKey!]
            let values = SecCertificateCopyValues(cert, keys, &err).takeUnretainedValue() as NSDictionary
            if let name = values[SecOIDX509V1SubjectNameKey!]?["value"]??[2]?["value"] as? String {
                if let identity = commonName?.takeUnretainedValue() {
                    self.init(name: name, identity: identity)
                    return
                }
            }
        }
        self.init(name: "", identity: "")
        return nil
    }
}

public func == (lhs: NetID, rhs: NetID) -> Bool {
    return lhs.identity == rhs.identity
}


@objc public class Connection: NSObject, NSStreamDelegate {
    
    struct Config {
        static let MaxBlockSize: Int = 1024
    }
    
    let inputStream: NSInputStream
    let outputStream: NSOutputStream
    
    var representedNetService: NSNetService?
    
    var acceptsInbound: Bool = false
    
    var inboundData: NSMutableData = NSMutableData()
    var outboundData: NSData?
    var outDataPointer: UnsafePointer<UInt8> = nil
    
    init(inputStream: NSInputStream,
        outputStream: NSOutputStream) {
            self.inputStream = inputStream
            self.outputStream = outputStream
            
            super.init()
            
            self.inputStream.delegate = self
            self.outputStream.delegate = self
    }
    
    func start() {
        if self.acceptsInbound {
            self.inputStream.setProperty(kCFStreamSocketSecurityLevelTLSv1, forKey: NSStreamSocketSecurityLevelKey)
            let sslSettings: CFDictionary = [
                //                kCFStreamSSLLevel as NSString: kCFStreamSocketSecurityLevelTLSv1,
                kCFStreamSSLValidatesCertificateChain as NSString: kCFBooleanFalse,
                kCFStreamSSLIsServer as NSString: (kCFBooleanFalse as AnyObject),
                kCFStreamSSLCertificates as NSString: tomIdentityChain
                //                kCFStreamSSLPeerName as NSString: "email:tom@example.com"
            ]
            CFReadStreamSetProperty(self.inputStream, kCFStreamPropertySSLSettings, sslSettings)
            
            self.inputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(),
                forMode:NSDefaultRunLoopMode)
            if self.inputStream.streamStatus == .NotOpen { self.inputStream.open() }
        }
        if let oData = self.outboundData {
            self.outputStream.setProperty(kCFStreamSocketSecurityLevelTLSv1, forKey: NSStreamSocketSecurityLevelKey)
            let sslSettings: NSDictionary = [
                //                kCFStreamSSLLevel as NSString: kCFStreamSocketSecurityLevelTLSv1,
                kCFStreamSSLValidatesCertificateChain as NSString: (kCFBooleanFalse as AnyObject),
                kCFStreamSSLCertificates as NSString: jimIdentityChain
                //                kCFStreamSSLPeerName: "email:tom@example.com"
            ]
            CFWriteStreamSetProperty(self.outputStream, kCFStreamPropertySSLSettings, sslSettings)
            
            self.outputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(),
                forMode:NSDefaultRunLoopMode)
            if self.outputStream.streamStatus == .NotOpen { self.outputStream.open() }
            self.outDataPointer = UnsafePointer<UInt8>(oData.bytes)
        }
    }
    
    func stopInputStream() {
        self.inputStream.close()
        self.inputStream.removeFromRunLoop(NSRunLoop.currentRunLoop(),
            forMode: NSDefaultRunLoopMode)
        self.inputStream.delegate = nil
    }
    
    func stopOutputStream() {
        self.outputStream.close()
        //        self.outputStream.removeFromRunLoop(NSRunLoop.currentRunLoop(),
        //            forMode: NSDefaultRunLoopMode)
        //        self.outputStream.delegate = nil
    }
    
    func stop() {
        self.stopInputStream()
        self.stopOutputStream()
    }
    
    func processInput() {
        //        println(NSString)
    }
    
    func stream(theStream: NSStream!, handleEvent streamEvent: NSStreamEvent) {
        if theStream == self.inputStream {
            let stream = self.inputStream
            switch (streamEvent) {
            case NSStreamEvent.OpenCompleted:
                println("\(representedNetService?.name)-Input: OpenCompleted")
                break
            case NSStreamEvent.HasBytesAvailable:
                if validateSecTrustOfStream(theStream) {
                    self.stop()
                    return
                }
                println("\(representedNetService?.name)-Input: HasBytesAvailable")
                println("kCFStreamPropertySocketRemoteHost: \(CFReadStreamCopyProperty(stream, kCFStreamPropertySocketRemoteHost))")
                let lengthToBeRead = Config.MaxBlockSize
                var buf = UnsafeMutablePointer<UInt8>.alloc(lengthToBeRead)
                let lenRead = inputStream.read(buf, maxLength: lengthToBeRead)
                if lenRead != 0 {
                    self.inboundData.appendBytes(buf, length: lenRead)
                } else {
                    println("no input data!")
                }
                println(NSString(data: self.inboundData, encoding: NSUTF8StringEncoding)!)
            case NSStreamEvent.ErrorOccurred:
                println("\(representedNetService?.name)-Input: ErrorOccurred")
                let err = stream.streamError
                if let theError = err {
                    NSLog("Error %li: %@", theError.code, theError.localizedDescription)
                }
                self.stopInputStream()
            case NSStreamEvent.EndEncountered:
                println("\(representedNetService?.name)-Input: EndEncountered")
                self.stopInputStream()
                self.processInput()
            default:
                println("Unhandled event code: \(streamEvent) for input stream: \(theStream)")
            }
        } else if theStream == self.outputStream {
            let stream = self.outputStream
            switch (streamEvent) {
            case NSStreamEvent.OpenCompleted:
                println("\(representedNetService?.name)-Output: OpenCompleted")
                break
            case NSStreamEvent.HasSpaceAvailable:
                if validateSecTrustOfStream(theStream) {
                    self.stop()
                    return
                }
                println("\(representedNetService?.name)-Output: HasSpaceAvailable")
                println("kCFStreamPropertySocketRemoteHost: \(CFWriteStreamCopyProperty(stream, kCFStreamPropertySocketRemoteHost))")
                if let outboundData = self.outboundData {
                    let totalLengthToBeWritten = outboundData.length - outboundData.bytes.distanceTo(self.outDataPointer)
                    println("totalLengthToBeWritten: \(totalLengthToBeWritten)")
                    let lengthToBeWritten = min(Config.MaxBlockSize, totalLengthToBeWritten)
                    let writenLen = outputStream.write(self.outDataPointer, maxLength: lengthToBeWritten)
                    println("writenLen \(writenLen)")
                    if writenLen > 0 {
                        self.outDataPointer = self.outDataPointer.advancedBy(writenLen)
                    } else {
                        println("no data written!")
                        //            return -1.0
                    }
                    println("totalLengthToBeWritten 2: \(outboundData.length - outboundData.bytes.distanceTo(self.outDataPointer))")
                    if (outboundData.length - outboundData.bytes.distanceTo(self.outDataPointer)) == 0 {
                        self.stop()
                    }
                }
            case NSStreamEvent.ErrorOccurred:
                println("\(representedNetService?.name)-Output: ErrorOccurred")
                let err = stream.streamError
                if let theError = err {
                    NSLog("Error %li: %@", theError.code, theError.localizedDescription)
                }
                self.stopOutputStream()
            case NSStreamEvent.EndEncountered:
                println("\(representedNetService?.name)-Output: EndEncountered")
                self.stopOutputStream()
            default:
                println("Unhandled event code: \(streamEvent) for output stream: \(theStream)")
            }
        }
    }
    
}


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
    
    func start() {
        self.netService.publishWithOptions(NSNetServiceOptions.ListenForConnections)
    }
    
    func stop() {
        self.netService.stop()
    }
    
    
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
        
    }
    
    /* Sent to the NSNetService instance's delegate when an error in publishing the instance occurs. The error dictionary will contain two key/value pairs representing the error domain and code (see the NSNetServicesError enumeration above for error code constants). It is possible for an error to occur after a successful publication.
    */
    public func netService(sender: NSNetService, didNotPublish errorDict: [NSObject : AnyObject]) {
        assert(sender === self.netService)
        
    }
    
    /* Sent to the NSNetService instance's delegate when the instance's previously running publication or resolution request has stopped.
    */
    public func netServiceDidStop(sender: NSNetService) {
        assert(sender === self.netService)
        
    }
    
    var connections = [Connection]()
    
    public func netService(sender: NSNetService, didAcceptConnectionWithInputStream inputStream: NSInputStream, outputStream: NSOutputStream) {
        let newConnection = Connection(inputStream: inputStream,
            outputStream: outputStream)
        newConnection.acceptsInbound = true
        newConnection.start()
        self.connections.append(newConnection)
    }
}

@objc class NetIDBrowser: NSObject, NSNetServiceBrowserDelegate {
    
    let browser = NSNetServiceBrowser()
    let runLoop = NSRunLoop.currentRunLoop()
    
    override init() {
        super.init()
        self.browser.delegate = self
        self.browser.includesPeerToPeer = true
        self.browser.scheduleInRunLoop(self.runLoop, forMode: NSDefaultRunLoopMode)
        self.browser.searchForServicesOfType(serviceType, inDomain: "")
    }
    
    /* Sent to the NSNetServiceBrowser instance's delegate before the instance begins a search. The delegate will not receive this message if the instance is unable to begin a search. Instead, the delegate will receive the -netServiceBrowser:didNotSearch: message.
    */
    func netServiceBrowserWillSearch(aNetServiceBrowser: NSNetServiceBrowser) {
        println("netServiceDomainBrowserWillSearch")
    }
    
    /* Sent to the NSNetServiceBrowser instance's delegate when the instance's previous running search request has stopped.
    */
    func netServiceBrowserDidStopSearch(aNetServiceBrowser: NSNetServiceBrowser) {
        self.browser.removeFromRunLoop(self.runLoop, forMode: NSDefaultRunLoopMode)
        self.browser.delegate = nil
        println("netServiceDomainBrowserDidStopSearch")
    }
    
    /* Sent to the NSNetServiceBrowser instance's delegate when an error in searching for domains or services has occurred. The error dictionary will contain two key/value pairs representing the error domain and code (see the NSNetServicesError enumeration above for error code constants). It is possible for an error to occur after a search has been started successfully.
    */
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didNotSearch errorDict: [NSObject : AnyObject]) {
        self.browser.removeFromRunLoop(self.runLoop, forMode: NSDefaultRunLoopMode)
        //        self.browser.delegate = nil
        println("netServiceDomainBrowserDidNotSearch: \(errorDict)")
    }
    
    var connections = [NSNetService: Connection]()
    
    /* Sent to the NSNetServiceBrowser instance's delegate for each service discovered. If there are more services, moreComing will be YES. If for some reason handling discovered services requires significant processing, accumulating services until moreComing is NO and then doing the processing in bulk fashion may be desirable.
    */
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didFindService aNetService: NSNetService, moreComing: Bool) {
        var ins: NSInputStream?
        var outs: NSOutputStream?
        let msgText = "Hello!"
        let msgData = msgText.dataUsingEncoding(NSUTF8StringEncoding)!
        var retrivedSuccessfully = aNetService.getInputStream(&ins, outputStream:&outs)
        if retrivedSuccessfully {
            if let inputStream = ins {
                if let outputStream = outs {
                    let newConnection = Connection(inputStream: inputStream,
                        outputStream: outputStream)
                    newConnection.outboundData = msgData
                    newConnection.start()
                    self.connections[aNetService] = newConnection
                }
            }
        }
    }
    
    /* Sent to the NSNetServiceBrowser instance's delegate when a previously discovered service is no longer published.
    */
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didRemoveService aNetService: NSNetService, moreComing: Bool) {
        if let newConnection = self.connections[aNetService] {
            newConnection.stop()
            self.connections[aNetService] = nil
        }
    }
}


let rootCert = importCertificateWithResourceName("NetIdentityCA")!
SecCertificateCopySubjectSummary(rootCert)

let attr: CFDictionary = [
    kSecClass as NSString: kSecClassCertificate as AnyObject,
    kSecValueRef: rootCert
]
SecItemDelete(attr)

//let mainBundle = NSBundle.mainBundle()
//var inputFormat: SecExternalFormat = SecExternalFormat(kSecFormatUnknown) // kSecFormatX509Cert // kSecFormatPKCS12
//var itemType: SecExternalItemType = SecExternalItemType(kSecItemTypeUnknown) // kSecItemTypeCertificate // kSecItemTypeAggregate
//let keyParamsPtr = UnsafeMutablePointer<SecItemImportExportKeyParameters>.alloc(1)
//memset(keyParamsPtr, 0, UInt(sizeof(SecItemImportExportKeyParameters)))
//var keyParams = keyParamsPtr.memory
////keyParams.version: uint32_t
//keyParams.flags = SecKeyImportExportFlags(kSecKeySecurePassphrase)
////keyParams.passphrase = "test"
////var at = UnsafeMutablePointer<CFString>(keyParams.alertTitle.toOpaque())
////Unmanaged<CFString>.passUnretained("SecItem Root Cert Import Alert Title")
////keyParams.alertPrompt = Unmanaged<CFString>.passUnretained("SecItem Root Cert Import Alert Prompt")
///* for import only */
////keyParams.accessRef: SecAccessRef
////keyParams.keyUsage: CFArray
////keyParams.keyAttributes: CFArray
//var outItems: Unmanaged<CFArray>?
//if let certificatePath = mainBundle.pathForResource("NetIdentityCA", ofType: "cer") {
//    if let certificateData = NSData(contentsOfFile: certificatePath) {
//        SecItemImport(certificateData,
//            "NetIdentityCA.cer",
//            &inputFormat,
//            &itemType,
//            SecItemImportExportFlags(0),
//            keyParamsPtr,
//            nil,
//            &outItems
//        )
//    }
//}
//let rootCertificate = { () -> SecCertificate in
//    (outItems!.takeUnretainedValue() as NSArray)[0] as SecCertificate
//}()
//var cn: Unmanaged<CFString>?
//SecCertificateCopyCommonName(rootCertificate, &cn)
//cn

let tomPKCS12Items = importCertsWithResourceName("tom")
//for item in tomPKCS12Items! {
//    println("{")
//    for (k, v) in item { println("  \(k): \(v)") }
//    println("}")
//}
let tomIdentity = tomPKCS12Items![0][SecImportItemIdentityKey] as SecIdentity
let tomChain = tomPKCS12Items![0][SecImportItemCertChainKey] as [SecCertificate]
let s = validateCertificateChain([tomChain[0]], forRootCertificate: rootCert, {
    (secTrustResult) -> Void in
    secTrustResult
    return
})
var tic: [AnyObject] = tomChain
tic[0] = tomIdentity
let tomIdentityChain: CFArray = tic
println(tomIdentityChain)
let tomNetID = NetID(secIdentity: tomIdentity)!
let tomAdvertizer = NetIDAdvertiser(netID: tomNetID, discoveryInfo: [:], serviceType: serviceType)
tomAdvertizer.start()

let jimPKCS12Items = importCertsWithResourceName("jim")
let jimIdentity = jimPKCS12Items![0][SecImportItemIdentityKey] as SecIdentity
let jimChain = jimPKCS12Items![0][SecImportItemCertChainKey] as [SecCertificate]
var jic: [AnyObject] = jimChain
jic[0] = jimIdentity
let jimIdentityChain: CFArray = jic
validateCertificateChain(jimChain, forRootCertificate: rootCert) {
    (secTrustResult) -> Void in
    secTrustResult
    return
}
let jimNetID = NetID(secIdentity: jimIdentity)!
//let jimAdvertizer = NetIDAdvertiser(netID: jimNetID, discoveryInfo: [:], serviceType: serviceType)

let browser = NetIDBrowser()



//while(true) {
//    NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate())
//    usleep(10)
//}

"End"

