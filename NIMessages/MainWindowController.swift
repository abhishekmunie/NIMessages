//
//  MainWindowController.swift
//  NIMessages
//
//  Created by Abhishek Munie on 21/10/14.
//  Copyright (c) 2014 Abhishek Munie. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        self.window?.titlebarAppearsTransparent = true
        self.window?.title = AppConfig.identityResourceName
    }

}
