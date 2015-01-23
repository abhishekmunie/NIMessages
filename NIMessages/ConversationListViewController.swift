//
//  ConversationListViewController.swift
//  NIMessages
//
//  Created by Abhishek Munie on 21/10/14.
//  Copyright (c) 2014 Abhishek Munie. All rights reserved.
//

import Cocoa

@objc protocol ConversationListViewControllerDelegate {
    
    func conversationListViewController(conversationListViewController: ConversationListViewController,
        didChangeSelectionTo selectedConversation: Conversation?)
}

private var myContext = 0

class ConversationListViewController: NSViewController, NSTableViewDelegate {
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        return ManagedObjectContext
        }()
    
    @IBOutlet weak var conversationListTableView: NSTableView!
    @IBOutlet weak var conversationArrayController: NSArrayController!
    
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var topToolView: NSVisualEffectView!
    
    weak var delegate: ConversationListViewControllerDelegate?
    
    private func adjustScrollViewOffset() {
        let offset: CGFloat = NSHeight(self.scrollView.frame) - NSMinY(self.topToolView.frame)
        self.scrollView.contentInsets = NSEdgeInsetsMake(offset, 0, 0, 0)
    }
    
    override func viewDidLoad() {
//        self.view.wantsLayer = true
        
        super.viewDidLoad()
        
        self.scrollView.automaticallyAdjustsContentInsets = false
        adjustScrollViewOffset()
        
        self.conversationArrayController.addObserver(self,
            forKeyPath: "selectionIndex",
            options: .New,
            context: &myContext)
    }
    
    
    var selectedConversation: Conversation? {
        get {
            let selectedObjects = self.conversationArrayController.selectedObjects
            if selectedObjects.count != 0 {
                return selectedObjects[0] as? Conversation
            }
            return nil
        }
        set (aConversation) {
            //            self.conversationsArrayController.selectedObjects = [aConversation]
        }
    }
    
    override func observeValueForKeyPath(keyPath: String,
        ofObject object: AnyObject,
        change: [NSObject : AnyObject],
        context: UnsafeMutablePointer<Void>) {
            if context == &myContext && object === self.conversationArrayController && keyPath == "selectionIndex" {
//                println("Changed conversationsArrayController.selectionIndex: \(change[NSKeyValueChangeNewKey])")
                self.delegate?.conversationListViewController(self, didChangeSelectionTo: self.selectedConversation)
            } else {
                super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            }
    }
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "showConversation" {
            assert(segue.destinationController is ConversationViewController)
            let selectedConversationViewController = segue.destinationController as ConversationViewController
            selectedConversationViewController.representedObject = selectedConversation
            println("Selected Conversation: \(selectedConversation?.peer.identity)")
        } else {
            assertionFailure("Unimplemented for segue: \(segue) with identifier: \(segue.identifier)")
        }
    }
    
    // MARK:- NSTableViewDelegate for conversationListTableView
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        assert(tableView === self.conversationListTableView)
        
//        if let columnCell = self.conversationListTableView.viewAtColumn(0, row: row, makeIfNecessary: false) as? NSView {
//            return columnCell.bounds.size.height
//        } else {
            return 51
//        }
    }
    
    func tableViewSelectionIsChanging(notification: NSNotification!) {
        
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        
    }
}
