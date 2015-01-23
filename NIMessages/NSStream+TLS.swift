//
//  NSStream+TLS.swift
//  NIMessages
//
//  Created by Abhishek Munie on 07/11/14.
//  Copyright (c) 2014 Abhishek Munie. All rights reserved.
//

import Foundation

extension NSStream {
    
    func am0_validateTrustWithRootCertificate(rootCertificate: SecCertificate) -> Bool {
        assert(self.streamStatus == .Reading || self.streamStatus == .Writing, "Required Trust data is available after the stream has been opened and available for reading/writing.")
        //    let certs: NSArray = self.propertyForKey(kCFStreamPropertySSLPeerCertificates as NSString)
        var trust = self.propertyForKey(kCFStreamPropertySSLPeerTrust) as SecTrust
        
        /* Because you don't want the array of certificates to keep
        growing, you should add the anchor to the trust list only
        upon the initial receipt of data (rather than every time).
        */
        let alreadyAdded = self.propertyForKey(kAnchorAlreadyAdded) as? Bool
        if alreadyAdded == nil || alreadyAdded! == false {
            trust = addAnchorToTrust(trust, rootCertificate) // defined earlier.
            self.setProperty((true as NSNumber), forKey: kAnchorAlreadyAdded)
        }
        var res: SecTrustResultType = SecTrustResultType(kSecTrustResultInvalid)
        logTrustResult(res)
        
        if SecTrustEvaluate(trust, &res) == noErr {
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
            println("SecTrustEvaluate Error")
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
            println("OK!")
            return true
        }
    }
    
    func am0_getPeerName() -> String? {
//        assert(self.streamStatus == .Reading || self.streamStatus == .Writing, "Required Trust data is available after the stream has been opened and available for reading/writing.")
        let trust = self.propertyForKey(kCFStreamPropertySSLPeerTrust) as SecTrust
        let certificate = SecTrustGetCertificateAtIndex(trust, 0).takeUnretainedValue()
        var cn: Unmanaged<CFString>? = nil
        SecCertificateCopyCommonName(certificate, &cn)
        return cn?.takeUnretainedValue()
    }
    
    func am0_getCertificate() -> SecCertificate? {
//        assert(self.streamStatus == .Reading || self.streamStatus == .Writing, "Required Trust data is available after the stream has been opened and available for reading/writing.")
        let trust = self.propertyForKey(kCFStreamPropertySSLPeerTrust) as SecTrust
        let certificate = SecTrustGetCertificateAtIndex(trust, 0).takeUnretainedValue()
        return certificate
    }
    
    func am_logTrustDetails() {
        let trust = self.propertyForKey(kCFStreamPropertySSLPeerTrust) as SecTrust
        logTrustDetails(trust)
    }
    
    public func am0_enableTLSWithCertificates(certificates: CFArray, isServer: CFBoolean) {
    }
}

extension NSInputStream {

    override public func am0_enableTLSWithCertificates(certificates: CFArray, isServer: CFBoolean) {
        super.am0_enableTLSWithCertificates(certificates, isServer: isServer)
        self.setProperty(kCFStreamSocketSecurityLevelTLSv1, forKey: NSStreamSocketSecurityLevelKey)
        let sslSettings: CFDictionary = [
            //                kCFStreamSSLLevel as NSString: kCFStreamSocketSecurityLevelTLSv1,
            kCFStreamSSLValidatesCertificateChain as NSString: kCFBooleanFalse,
            kCFStreamSSLIsServer as NSString: isServer,
            kCFStreamSSLCertificates as NSString: certificates
        ]
        CFReadStreamSetProperty(self, kCFStreamPropertySSLSettings, sslSettings)
        
        if isServer == kCFBooleanTrue {
            let context = CFReadStreamCopyProperty(self, kCFStreamPropertySSLContext) as SSLContext
            let success = SSLSetClientSideAuthenticate(context, kAlwaysAuthenticate)
            println("SSLSetClientSideAuthenticate: \(success)")
        }
    }
}

extension NSOutputStream {
    
    override public func am0_enableTLSWithCertificates(certificates: CFArray, isServer: CFBoolean) {
        super.am0_enableTLSWithCertificates(certificates, isServer: isServer)
        self.setProperty(kCFStreamSocketSecurityLevelTLSv1, forKey: NSStreamSocketSecurityLevelKey)
        let sslSettings: NSDictionary = [
            //                kCFStreamSSLLevel as NSString: kCFStreamSocketSecurityLevelTLSv1,
            kCFStreamSSLValidatesCertificateChain as NSString: kCFBooleanFalse,
            kCFStreamSSLIsServer as NSString: isServer,
            kCFStreamSSLCertificates as NSString: certificates
        ]
        CFWriteStreamSetProperty(self, kCFStreamPropertySSLSettings, sslSettings)
        
        if isServer == kCFBooleanTrue {
            let context = CFWriteStreamCopyProperty(self, kCFStreamPropertySSLContext) as SSLContext
            let success = SSLSetClientSideAuthenticate(context, kAlwaysAuthenticate)
            println("SSLSetClientSideAuthenticate: \(success)")
        }
    }
}
