//
//  MainSplitViewController.swift
//  NIMessages
//
//  Created by Abhishek Munie on 21/10/14.
//  Copyright (c) 2014 Abhishek Munie. All rights reserved.
//

import Cocoa

class MainSplitViewController: NSSplitViewController, ConversationListViewControllerDelegate {
    
    var conversationListViewController: ConversationListViewController?
    var conversationViewController: ConversationViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        for splitView in self.splitViewItems as [NSSplitViewItem] {
            let viewController = splitView.viewController
            if let conversationListViewController = viewController as? ConversationListViewController {
                //            conversationListViewController.conversationsArrayController = self.conversationsArrayController
                conversationListViewController.delegate = self
                self.conversationListViewController = conversationListViewController
            } else if let conversationViewController = viewController as? ConversationViewController {
                //            conversationViewController.conversationsArrayController = self.conversationsArrayController
                self.conversationViewController = conversationViewController
            } else {
                assertionFailure("Unexpected splitViewItem: \(splitView)")
            }
        }
    }
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject!) {
        //        let destinationController = segue.destinationController
        //        if let conversationListViewController = destinationController as? ConversationListViewController {
        ////            conversationListViewController.conversationsArrayController = self.conversationsArrayController
        //            conversationListViewController.delegate = self
        //            self.conversationListViewController = conversationListViewController
        //        } else if let conversationViewController = destinationController as? ConversationViewController {
        ////            conversationViewController.conversationsArrayController = self.conversationsArrayController
        //            self.conversationViewController = conversationViewController
        //        } else {
        //            assertionFailure("Unimplemented for segue: \(segue) with identifier: \(segue.identifier)")
        //        }
    }
    
    
    func conversationListViewController(conversationListViewController: ConversationListViewController,
        didChangeSelectionTo selectedConversation: Conversation?) {
            println("Selected Conversation: \(selectedConversation?.peer.identity)")
            self.conversationViewController?.representedObject = selectedConversation
    }
}
