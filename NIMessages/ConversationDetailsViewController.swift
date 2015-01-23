//
//  ConversationDetailsViewController.swift
//  NIMessages
//
//  Created by Abhishek Munie on 24/10/14.
//  Copyright (c) 2014 Abhishek Munie. All rights reserved.
//

import Cocoa

class ConversationDetailsViewController: NSViewController {
    
    lazy var managedObjectContext: NSManagedObjectContext = ManagedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
            if let newRepresentedConversation = self.representedObject as? Conversation {
                if newRepresentedConversation !== self.representedConversation {
                    self.representedConversation = newRepresentedConversation
                }
            } else {
                self.representedConversation = nil
            }
        }
    }
    
    dynamic var representedConversation: Conversation! //{
//        didSet { self.representedObject = self.representedConversation }
//    }
    
}
