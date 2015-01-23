//
//  NetID.swift
//  NIMessagesSimple
//
//  Created by Abhishek Munie on 07/10/14.
//  Copyright (c) 2014 Abhishek Munie. All rights reserved.
//

import Cocoa
import Security

@objc public class NetID: NSObject, Hashable, NSSecureCoding {
    
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
    
    convenience init?(peerNetService aNSNetService: NSNetService) {
        let string = aNSNetService.name as NSString
        var err: NSError?
        if let regex = NSRegularExpression(pattern: "([^<]*)\\<([^>]*)\\>\\(([^>]*)\\)", options: nil, error: &err) {
            var range = NSRange(location: 0, length: string.length)
            let res = regex.matchesInString(string, options: nil, range: range)
            let res0 = res[0] as NSTextCheckingResult
            
            if res0.numberOfRanges == 4 {
                let identifier = string.substringWithRange(res0.rangeAtIndex(0))
                let name = string.substringWithRange(res0.rangeAtIndex(1))
                let identity = string.substringWithRange(res0.rangeAtIndex(2))
                let uuid = string.substringWithRange(res0.rangeAtIndex(3))
                self.init(name: name, identity: identity, uuid: uuid)
            } else {
                self.init(name: "", identity: "", uuid: "")
                return nil
            }
        } else {
            self.init(name: "", identity: "", uuid: "")
            return nil
        }
    }
    
    public convenience init?(certificate: SecCertificate) {
        var commonName: Unmanaged<CFString>?
        var emailAddresses: Unmanaged<CFArray>?
        var err: Unmanaged<CFError>?
        SecCertificateCopyCommonName(certificate, &commonName)
        let keys = [SecOIDX509V1SubjectNameKey!]
        let values = SecCertificateCopyValues(certificate, keys, &err).takeUnretainedValue() as NSDictionary
        if let name = values[SecOIDX509V1SubjectNameKey!]?["value"]??[2]?["value"] as? String {
            if let identity = commonName?.takeUnretainedValue() {
                self.init(name: name, identity: identity)
                return
            }
        }
        self.init(name: "", identity: "", uuid: "")
        return nil
    }
    
    convenience init?(certificate: SecCertificate, uuid: String) {
        var commonName: Unmanaged<CFString>?
        var emailAddresses: Unmanaged<CFArray>?
        var err: Unmanaged<CFError>?
        SecCertificateCopyCommonName(certificate, &commonName)
        let keys = [SecOIDX509V1SubjectNameKey!]
        let values = SecCertificateCopyValues(certificate, keys, &err).takeUnretainedValue() as NSDictionary
        if let name = values[SecOIDX509V1SubjectNameKey!]?["value"]??[2]?["value"] as? String {
            if let identity = commonName?.takeUnretainedValue() {
                println("name: \(name); identity: \(identity)")
                self.init(name: name, identity: identity, uuid: uuid)
                return
            }
        }
        self.init(name: "", identity: "", uuid: "")
        return nil
    }
    
    public convenience init?(secIdentity: SecIdentity) {
        var certificate: Unmanaged<SecCertificate>?
        SecIdentityCopyCertificate(secIdentity, &certificate)
        if let cert = certificate?.takeUnretainedValue() {
            self.init(certificate: cert)
            return
        }
        self.init(name: "", identity: "")
        return nil
    }
    
    class func identityFromIdentifier(string: NSString) -> String? {
        var err: NSError?
        if let regex = NSRegularExpression(pattern: "([^<]*)\\<([^>]*)\\>\\(([^>]*)\\)", options: nil, error: &err) {
            var r = NSRange(location: 0, length: string.length)
            let res = regex.matchesInString(string, options: nil, range: r)
            let res0 = res[0] as NSTextCheckingResult
            
            if res0.numberOfRanges == 4 {
                //                let identifier = string.substringWithRange(res0.rangeAtIndex(0))
                //                let name = string.substringWithRange(res0.rangeAtIndex(1))
                let identity = string.substringWithRange(res0.rangeAtIndex(2))
                //                let uuid = string.substringWithRange(res0.rangeAtIndex(3))
                return identity
            }
        }
        return nil
    }
    
    var email: String? {
        return NetID.emailFromIdentity(self.identity)
    }
    
    class func emailFromIdentity(identity: String) -> String? {
        if identity[identity.startIndex...advance(identity.startIndex, 5, identity.endIndex)] == "email:" {
            let email = identity[advance(identity.startIndex, 6, identity.endIndex)..<identity.endIndex]
            return email
        }
        return nil
    }
    
    class func uuidFromIdentifier(string: NSString) -> String? {
        var err: NSError?
        if let regex = NSRegularExpression(pattern: "([^<]*)\\<([^>]*)\\>\\(([^>]*)\\)", options: nil, error: &err) {
            var r = NSRange(location: 0, length: string.length)
            let res = regex.matchesInString(string, options: nil, range: r)
            let res0 = res[0] as NSTextCheckingResult
            
            if res0.numberOfRanges == 4 {
                //                let identifier = string.substringWithRange(res0.rangeAtIndex(0))
                //                let name = string.substringWithRange(res0.rangeAtIndex(1))
                //                let identity = string.substringWithRange(res0.rangeAtIndex(2))
                let uuid = string.substringWithRange(res0.rangeAtIndex(3))
                return uuid
            }
        }
        return nil
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
    
    
    // MARK: - NSSecureCoding
    
    public required init(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObjectOfClass(NSString.self, forKey: "name")! as NSString as String
        self.identity = aDecoder.decodeObjectOfClass(NSString.self, forKey: "identity")! as NSString as String
        self.uuid = aDecoder.decodeObjectOfClass(NSString.self, forKey: "uuid")! as NSString as String
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.name as NSString, forKey: "name")
        aCoder.encodeObject(self.identity as NSString, forKey: "identity")
        aCoder.encodeObject(self.uuid as NSString, forKey:  "uuid")
    }
    
    public class func supportsSecureCoding() -> Bool { return true }
    
    //    var certificate: SecCertificate?
    //    var publicKey: SecKey?
    //    var privateKey: SecKey?
    //
    //    public init(certificate: SecCertificate,
    //        publicKey: SecKey,
    //        privateKey: SecKey) {
    //            self.name = name
    //            self.identity = identity
    //            self.certificate = certificate
    //            self.publicKey = publicKey
    //            self.privateKey = privateKey
    //    }
    //
    //    // For initializing peer net id from within framework
    //    init(certificate: SecCertificate,
    //        publicKey: SecKey) {
    //            self.name = name
    //            self.identity = identity
    //            self.certificate = certificate
    //            self.publicKey = publicKey
    //    }
    
    
    
    // MARK: - Debug Helpers
    
    public func debugQuickLookObject() -> AnyObject {
        let qlString = NSMutableAttributedString()
        
        return qlString
    }
}

public func == (lhs: NetID, rhs: NetID) -> Bool {
    return lhs.identity == rhs.identity
}
