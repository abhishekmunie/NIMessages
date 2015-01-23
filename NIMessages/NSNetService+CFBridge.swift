//
//  NSNetService+CFBridge.swift
//  NIMessages
//
//  Created by Abhishek Munie on 03/11/14.
//  Copyright (c) 2014 Abhishek Munie. All rights reserved.
//

import Cocoa

extension NSNetService {

    var am0_CFNetService: CFNetService {
        let netService = CFNetServiceCreate(kCFAllocatorDefault,
            self.domain, self.type, self.name, Int32(self.port))
        return netService.takeUnretainedValue()
    }
}
