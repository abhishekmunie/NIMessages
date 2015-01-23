//
//  SecItemUtilities.swift
//  NIMessages
//
//  Created by Abhishek Munie on 12/11/14.
//  Copyright (c) 2014 Abhishek Munie. All rights reserved.
//

import Foundation
import Security
import CoreServices

func addCertificate(certificate: SecCertificate) -> OSStatus {
    let attr: CFDictionary = [
        (kSecClass as NSString): (kSecClassCertificate as AnyObject),
        //        kSecAttrSynchronizable: true,
        kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock,
        kSecValueData: certificate
    ]
    
    let status: OSStatus = SecItemAdd(attr, nil)
    return status
}

//func getCertificate() -> String? {
//    let query: CFDictionary = [
//        (kSecClass as NSString): (kSecClassCertificate as AnyObject),
//        kSecReturnData: true
//        //        kSecUseOperationPrompt: "Test"
//    ]
//    var data: Unmanaged<AnyObject>?
//    
//    let status: OSStatus = SecItemCopyMatching(query, &data)
//    if status == noErr {
//        if let secret = data?.takeUnretainedValue() as? NSData {
//            return NSString(data: secret, encoding: NSUTF8StringEncoding)!
//        }
//    } else if status == errSecItemNotFound {}
//    return nil
//}
//
//func changeItem() -> OSStatus {
//    let query: CFDictionary = [
//        (kSecClass as NSString): (kSecClassGenericPassword as AnyObject),
//        kSecAttrService: "com.abhishekmunie.com",
//        kSecAttrAccount: "mySecAccount"
//    ]
//    let secretText = "New Top Secret"
//    let secretData = secretText.dataUsingEncoding(NSUTF8StringEncoding)!
//    let newAttr: CFDictionary = [
//        (kSecClass as NSString): (kSecClassGenericPassword as AnyObject),
//        kSecAttrService: "com.abhishekmunie.com",
//        kSecAttrAccount: "mySecAccount",
//        kSecValueData: secretData
//    ]
//    
//    let status: OSStatus = SecItemUpdate(query, newAttr)
//    return status
//}
//
//func deleteItem() -> OSStatus {
//    let query: CFDictionary = [
//        (kSecClass as NSString): (kSecClassGenericPassword as AnyObject),
//        kSecAttrService: "com.abhishekmunie.com",
//        kSecAttrAccount: "mySecAccount"
//    ]
//    
//    let status: OSStatus = SecItemDelete(query)
//    return status
//}

