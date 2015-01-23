//
//  Constants.swift
//  NIMessages
//
//  Created by Abhishek Munie on 12/11/14.
//  Copyright (c) 2014 Abhishek Munie. All rights reserved.
//

import Foundation
import Security
import CoreServices


let SecImportExportPassphraseKey = kSecImportExportPassphrase!.takeUnretainedValue() as NSString
let SecOIDOrganizationNameKey: AnyObject?  = kSecOIDOrganizationName?.takeUnretainedValue()
let SecOIDX509V1SubjectNameKey = kSecOIDX509V1SubjectName?.takeUnretainedValue() as? NSString
let SecImportItemIdentityKey = kSecImportItemIdentity!.takeUnretainedValue() as NSString
let SecImportItemCertChainKey = kSecImportItemCertChain!.takeUnretainedValue() as NSString

let kAnchorAlreadyAdded: NSString = "AnchorAlreadyAdded"

