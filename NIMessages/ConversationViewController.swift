//
//  ConversationViewController.swift
//  NIMessages
//
//  Created by Abhishek Munie on 21/10/14.
//  Copyright (c) 2014 Abhishek Munie. All rights reserved.
//

import Cocoa

class ConversationViewController: NSViewController, NSTableViewDelegate {
    
    lazy var managedObjectContext: NSManagedObjectContext = ManagedObjectContext
    
    @IBOutlet var messagesArrayController: NSArrayController!
    
    @IBOutlet weak var messagesScrollView: NSScrollView!
    @IBOutlet weak var messagesTableView: NSTableView!
    @IBOutlet weak var topBarVisualEffectView: NSVisualEffectView!
    @IBOutlet weak var newMessageBarVisualEffectView: NSVisualEffectView!
    @IBOutlet var newMessageTextField: NSTextField!
    
    lazy var messagesSortDescriptor: NSArray = [NSSortDescriptor(key:"date", ascending:true)]
    
    private func adjustScrollViewOffset() {
        let topOffset: CGFloat = NSHeight(self.messagesScrollView.frame) - NSMinY(self.topBarVisualEffectView.frame)
        let bottomOffset: CGFloat = NSMaxY(self.newMessageBarVisualEffectView.frame)
        self.messagesScrollView.contentInsets = NSEdgeInsetsMake(topOffset, 0, bottomOffset, 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.messagesScrollView.automaticallyAdjustsContentInsets = false
        adjustScrollViewOffset()
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
            if let newRepresentedConversation = self.representedObject as? Conversation {
                if newRepresentedConversation !== self.representedConversation {
                    self.representedConversation = newRepresentedConversation
//                    if AppConfig.identityResourceName == "Alfred" {
//                    dispatch_async(dispatch_get_main_queue()) {
//                        for i in 0...1000 {
//                            self.sendMessageString("Hi")
//                        }
//                    }
//                    }
                }
            } else {
//                if self.representedConversation != nil {
                self.representedConversation = nil
//                }
            }
        }
    }
    
    dynamic var representedConversation: Conversation! //{
//        didSet { self.representedObject = self.representedConversation }
//    }
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "showDetails" {
            assert(segue.destinationController is ConversationDetailsViewController)
            let detailsViewController = segue.destinationController as ConversationDetailsViewController
            detailsViewController.representedObject = self.representedConversation
            println("Details of Conversation: \(self.representedConversation?.peer.identity)")
        } else {
            assertionFailure("Unimplemented for segue: \(segue) with identifier: \(segue.identifier)")
        }
    }
    
    private func sendMessageString(msgString: String) {
        var err: NSError?
        let msgData = msgString.dataUsingEncoding(NSUTF8StringEncoding)!
        let success = netIDHandler.sendData(msgData,
            toPeersWithIdentity: self.representedConversation.peer.identity,
            withMode: .Reliable,
            error: &err)
        if success {
            let message = Message.messageWithText(msgString,
                date: NSDate(),
                sender: MyPeerObject,
                conversation: self.representedConversation!,
                inManagedObjectContext: ManagedObjectContext)
        } else {
            NSLog("Error while sending msg \"\(msgString)\" \(err?.code): \(err?.localizedDescription)")
        }
    }
    
    @IBAction func sendMessage(sender: NSTextField) {
        assert(sender === self.newMessageTextField)
        let msgText = sender.stringValue
        sendMessageString(msgText)
        sender.stringValue = ""
    }
    
    // MARK:- NSTableViewDelegate for messagesTableView
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        assert(tableView === self.messagesTableView)
        
        //        if let columnCell = self.conversationListTableView.viewAtColumn(0, row: row, makeIfNecessary: false) as? NSView {
        //            return columnCell.bounds.size.height
        //        } else {
        return 51
        //        }
    }
    
    func tableView(tableView: NSTableView,
        viewForTableColumn tableColumn: NSTableColumn?,
        row: Int) -> NSView? {
            if let messages = self.messagesArrayController.arrangedObjects as? [Message] {
                let message = messages[row]
                if message.sender == MyPeerObject {
                    return tableView.makeViewWithIdentifier("SentMessage", owner: self) as? NSView
                } else {
                    return tableView.makeViewWithIdentifier("ReceivedMessage", owner: self) as? NSView
                }
            }
            return nil
    }
}
