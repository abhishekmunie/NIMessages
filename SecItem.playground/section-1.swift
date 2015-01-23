// Playground - noun: a place where people can play

import Cocoa
import Security
import CoreServices

func addItem() -> OSStatus {
    let secretText = "Top Secret"
    let secretData = secretText.dataUsingEncoding(NSUTF8StringEncoding)!
    let attr: CFDictionary = [
        (kSecClass as NSString): (kSecClassGenericPassword as AnyObject),
        kSecAttrService: "com.abhishekmunie.com",
        kSecAttrAccount: "mySecAccount",
        //        kSecAttrSynchronizable: true,
        kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock,
        kSecValueData: secretData
    ]
    
    let status: OSStatus = SecItemAdd(attr, nil)
    return status
}

func getItem() -> String? {
    let query: CFDictionary = [
        (kSecClass as NSString): (kSecClassGenericPassword as AnyObject),
        kSecAttrService: "com.abhishekmunie.com",
        kSecAttrAccount: "mySecAccount",
        kSecReturnData: true
        //        kSecUseOperationPrompt: "Test"
    ]
    var data: Unmanaged<AnyObject>?
    
    let status: OSStatus = SecItemCopyMatching(query, &data)
    if status == noErr {
        if let secret = data?.takeUnretainedValue() as? NSData {
            return NSString(data: secret, encoding: NSUTF8StringEncoding)!
        }
    } else if status == errSecItemNotFound {}
    return nil
}

func changeItem() -> OSStatus {
    let query: CFDictionary = [
        (kSecClass as NSString): (kSecClassGenericPassword as AnyObject),
        kSecAttrService: "com.abhishekmunie.com",
        kSecAttrAccount: "mySecAccount"
    ]
    let secretText = "New Top Secret"
    let secretData = secretText.dataUsingEncoding(NSUTF8StringEncoding)!
    let newAttr: CFDictionary = [
        (kSecClass as NSString): (kSecClassGenericPassword as AnyObject),
        kSecAttrService: "com.abhishekmunie.com",
        kSecAttrAccount: "mySecAccount",
        kSecValueData: secretData
    ]
    
    let status: OSStatus = SecItemUpdate(query, newAttr)
    return status
}

func deleteItem() -> OSStatus {
    let query: CFDictionary = [
        (kSecClass as NSString): (kSecClassGenericPassword as AnyObject),
        kSecAttrService: "com.abhishekmunie.com",
        kSecAttrAccount: "mySecAccount"
    ]
    
    let status: OSStatus = SecItemDelete(query)
    return status
}

SecCopyErrorMessageString(addItem(), nil).takeUnretainedValue()
getItem()
SecCopyErrorMessageString(changeItem(), nil).takeUnretainedValue()
getItem()
SecCopyErrorMessageString(deleteItem(), nil).takeUnretainedValue()
getItem()
