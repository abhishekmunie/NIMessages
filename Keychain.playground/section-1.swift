import Foundation
import Security
import CoreServices


let passKey = kSecImportExportPassphrase.takeUnretainedValue() as NSString

func importCerts(data: CFData) -> [[NSString: AnyObject]]? {
    var certs: Unmanaged<CFArray>?
    let options: CFDictionary = [
        passKey: "test"
    ]
    let status = SecPKCS12Import(data, options, &certs)
    SecCopyErrorMessageString(status, nil).takeUnretainedValue()
    if status == noErr {
        if let res = certs?.takeUnretainedValue() as? [[NSString: AnyObject]] {
            return res
        }
    } else if status == errSecItemNotFound {}
    return nil
}

let mainBundle = NSBundle.mainBundle()

let rootCertPath = mainBundle.pathForResource("NetIdentityCA", ofType: "cer")!
let rootCertData = NSData(contentsOfFile: rootCertPath)!
let rootCert = SecCertificateCreateWithData(nil, rootCertData).takeUnretainedValue()
SecCertificateCopySubjectSummary(rootCert)

let NIUser0Path = mainBundle.pathForResource("identity", ofType: "p12")!
let NIUser0Data = NSData(contentsOfFile: NIUser0Path)!
NIUser0Data.length
let NIUser0PKCS12Items = importCerts(NIUser0Data)
for item in NIUser0PKCS12Items! {
    println("{")
    for (k, v) in item { println("    \(k): \(v)") }
    println("}")
}
let NIUser0Identity = NIUser0PKCS12Items![0][kSecImportItemIdentity.takeUnretainedValue() as NSString] as SecIdentity
let NIUser0Chain = NIUser0PKCS12Items![0][kSecImportItemCertChain.takeUnretainedValue() as NSString] as CFArray

//let nonNIUser0Path  = mainBundle.pathForResource("NonNIUser0", ofType: "p12")!
//let nonNIUser0Data = NSData(contentsOfFile: nonNIUser0Path)!
//nonNIUser0Data.length
//let nonNIUser0PKCS12Items = importCerts(nonNIUser0Data)
//let nonNIUser0Identity = nonNIUser0PKCS12Items![0][kSecImportItemIdentity.takeUnretainedValue() as NSString] as SecIdentity
//let nonNIUser0Chain = nonNIUser0PKCS12Items![0][kSecImportItemCertChain.takeUnretainedValue() as NSString] as CFArray


let basicPolicy = SecPolicyCreateBasicX509().takeUnretainedValue()
let policy = NSArray(object: basicPolicy)
let certificates = NIUser0Chain
var trustR: Unmanaged<SecTrust>?
SecTrustCreateWithCertificates(certificates, policy, &trustR)
if let trust = trustR?.takeUnretainedValue() {
    SecTrustSetAnchorCertificates(trust, NSArray(object: rootCert))
    
    var resultPtr = UnsafeMutablePointer<SecTrustResultType>.alloc(1)
    SecTrustEvaluate(trust, resultPtr)
    Int(resultPtr.memory) == kSecTrustResultUnspecified || Int(resultPtr.memory) == kSecTrustResultProceed
}

//func changeHostForTrust(trust: SecTrust, toHost host: String) -> SecTrust? {
////    var newTrustPolicies = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks)
//    var newTrustPolicies = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, [])
//    
//    let sslPolicy = SecPolicyCreateSSL(1, host).takeUnretainedValue()
//    
//    withUnsafePointer(&sslPolicy, { (sslPolicyPtr) -> Void in
//        return CFArrayAppendValue(newTrustPolicies, sslPolicyPtr)
//    })
//    
//    /* This technique works in iOS 2 and later, or
//    OS X v10.7 and later */
//    
//    var certificates: CFMutableArray = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, [])
//    
//    /* Copy the certificates from the original trust object */
//    let count = SecTrustGetCertificateCount(trust)
//    var i: CFIndex = 0
//    for i = 0; i < count; i++ {
//        let item = SecTrustGetCertificateAtIndex(trust, i).takeUnretainedValue()
//        withUnsafePointer(&item, { (itemPtr) -> Result in
//            
//        })
//        CFArrayAppendValue(certificates, &item)
//    }
//    
//    /* Create a new trust object */
//    var newtrust: Unmanaged<SecTrust>?
//    if (SecTrustCreateWithCertificates(certificates, newTrustPolicies, &newtrust) != errSecSuccess) {
//        /* Probably a good spot to log something. */
//        
//        return nil
//    }
//    
//    return newtrust?.takeUnretainedValue()
//}



func addItem() -> OSStatus {
    let secretText = "Top Secret"
    let secretData = secretText.dataUsingEncoding(NSUTF8StringEncoding)!
    let attr: CFDictionary = [
        (kSecClass as NSString): (kSecClassIdentity as AnyObject),
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

func deleteItem() -> OSStatus {
    let query: CFDictionary = [
        (kSecClass as NSString): (kSecClassGenericPassword as AnyObject),
        kSecAttrService: "com.abhishekmunie.com",
        kSecAttrAccount: "mySecAccount"
    ]
    
    let status: OSStatus = SecItemDelete(query)
    return status
}
