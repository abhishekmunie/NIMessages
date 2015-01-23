//
//  SecurityUtlities.swift
//  NIMessages
//
//  Created by Abhishek Munie on 12/11/14.
//  Copyright (c) 2014 Abhishek Munie. All rights reserved.
//

import Foundation
import Security
import CoreServices

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

func importPKCS12WithResourceName(resourceName: String) -> [[String: AnyObject]]? {
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

func importCertificateSecItemWithResourceName(resourceName: String) -> SecCertificate? {
    let mainBundle = NSBundle.mainBundle()
    var inputFormat: SecExternalFormat = SecExternalFormat(kSecFormatX509Cert) // kSecFormatUnknown // kSecFormatPKCS12
    var itemType: SecExternalItemType = SecExternalItemType(kSecItemTypeCertificate) // kSecItemTypeUnknown // kSecItemTypeAggregate
    let keyParamsPtr = UnsafeMutablePointer<SecItemImportExportKeyParameters>.alloc(1)
    memset(keyParamsPtr, 0, UInt(sizeof(SecItemImportExportKeyParameters)))
    var keyParams = keyParamsPtr.memory
//    keyParams.version: uint32_t
//    keyParams.flags = SecKeyImportExportFlags(kSecKeySecurePassphrase)
//    keyParams.passphrase = "test"
//    var at = UnsafeMutablePointer<CFString>(keyParams.alertTitle.toOpaque())
//    Unmanaged<CFString>.passUnretained("SecItem Root Cert Import Alert Title")
//    keyParams.alertPrompt = Unmanaged<CFString>.passUnretained("SecItem Root Cert Import Alert Prompt")
//    for import only
//    keyParams.accessRef: SecAccessRef
//    keyParams.keyUsage: CFArray
//    keyParams.keyAttributes: CFArray
    var outItems: Unmanaged<CFArray>?
    if let certificatePath = mainBundle.pathForResource(resourceName, ofType: "cer") {
        if let certificateData = NSData(contentsOfFile: certificatePath) {
            SecItemImport(certificateData,
                "\(resourceName).cer",
                &inputFormat,
                &itemType,
                SecItemImportExportFlags(0),
                keyParamsPtr,
                nil,
                &outItems
            )
        }
    }
    if let oi = outItems?.takeUnretainedValue() {
        let nsoi = oi as NSArray
        let certificate = nsoi[0] as SecCertificate
        return certificate
    }
    return nil
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

func addAnchorToTrust(trust: SecTrust, trustedCert: SecCertificate) -> SecTrust {
    let newAnchorArray: CFArray = [trustedCert]
    
    SecTrustSetAnchorCertificates(trust, newAnchorArray)
    return trust
}

func logTrustResult(trustResult: SecTrustResultType) {
    var trustResultStr: String
    switch (trustResult) {
    case SecTrustResultType(kSecTrustResultInvalid):                 trustResultStr = "invalid"
    case SecTrustResultType(kSecTrustResultProceed):                 trustResultStr = "proceed"
    case SecTrustResultType(kSecTrustResultDeny):                    trustResultStr = "deny"
    case SecTrustResultType(kSecTrustResultUnspecified):             trustResultStr = "unspecified"
    case SecTrustResultType(kSecTrustResultRecoverableTrustFailure): trustResultStr = "recoverable trust failure"
    case SecTrustResultType(kSecTrustResultFatalTrustFailure):       trustResultStr = "Fatal trust failure"
    case SecTrustResultType(kSecTrustResultOtherError):              trustResultStr = "other error"
    default:                                                         trustResultStr = NSString(format:"%u", trustResult)
    }
    println("Trust Result: \(trustResultStr)")
}

func logTrustDetails(trust: SecTrust) {
    var err: OSStatus
    var trustResult: SecTrustResultType
    var certificateCount: CFIndex
    var certificateIndex: CFIndex
    
    certificateCount = SecTrustGetCertificateCount(trust)
    println("Certificate Details:")
    for certificateIndex = 0; certificateIndex < certificateCount; certificateIndex++ {
        println("  \(certificateIndex): \(SecCertificateCopySubjectSummary(SecTrustGetCertificateAtIndex(trust, certificateIndex).takeUnretainedValue()).takeUnretainedValue())")
    }
}




