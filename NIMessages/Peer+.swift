//
//  Peer+.swift
//  NIMessagesSimple
//
//  Created by Abhishek Munie on 23/09/14.
//  Copyright (c) 2014 Abhishek Munie. All rights reserved.
//

import Cocoa
import AddressBook

private let _entityName = "Peer"

private func circularImageFromImage(image: NSImage) -> NSImage {
    let rect = NSRect(origin: NSZeroPoint, size: image.size)
    let clipPath = NSBezierPath(ovalInRect: rect)
    
    let imageSize = image.size
    let clipedImage = NSImage(size: imageSize, flipped: false) { (rect) -> Bool in
        clipPath.addClip()
        image.drawInRect(rect, fromRect: NSZeroRect, operation: .CompositeSourceOver, fraction: 1.0)
        //            NSColor(white: 1.0, alpha: 1.0 - self.saturation).set()
        return true
    }
    return clipedImage
}

extension Peer {
    
    class var entityName: String { return _entityName }
    
    
    class func insertNewPeerInManagedObjectContext(context: NSManagedObjectContext) -> Peer {
        println("Inserting new Peer")
        return NSEntityDescription.insertNewObjectForEntityForName(self.entityName,
            inManagedObjectContext: context) as Peer
    }
    
    class func fetchPeerWithIdentity(identity: String,
        inManagedObjectContext context: NSManagedObjectContext) -> Peer? {
            var request = NSFetchRequest()
            var entity = NSEntityDescription.entityForName(self.entityName,
                inManagedObjectContext: context)
            request.entity = entity
            
            var predicate = NSPredicate(format:"identity == %@", identity)
            request.predicate = predicate
            request.fetchLimit = 1
            
            var error: NSError?
            var possibleObjects = context.executeFetchRequest(request, error:&error)
            if let objects = possibleObjects {
                var count = objects.count // May be 0 if the object has been deleted.
                if count != 0 {
                    return (objects[0] as Peer)
                } else {
                    return nil
                }
            } else {
                // Deal with error.
                assertionFailure("\(self.entityName) Fetch Failed for Identity<\(identity)>: \(error?.localizedDescription)\n\(error?.userInfo)")
                return nil
            }
    }
    
//    class func peerWithIdentity(identity: String,
//        netService: NSNetService?,
//        inManagedObjectContext context: NSManagedObjectContext) -> Peer {
//            var possibleExistingPeer = fetchPeerWithIdentity(identity, inManagedObjectContext: context)
//            if let peer = possibleExistingPeer {
//                return peer
//            } else {
//                var peer = insertNewPeerInManagedObjectContext(context)
//                peer.identity = identity
//                peer.netService = netService
//                var conversation = Conversation.conversationWithPeer(peer,
//                    inManagedObjectContext: context)
//                peer.conversation = conversation
//                return peer
//            }
//    }
    class func peerWithIdentity(identity: String,
        name: String,
        inManagedObjectContext context: NSManagedObjectContext) -> Peer {
            var possibleExistingPeer = fetchPeerWithIdentity(identity, inManagedObjectContext: context)
            if let peer = possibleExistingPeer {
                return peer
            } else {
                var peer = insertNewPeerInManagedObjectContext(context)
                peer.identity = identity
                peer.name = name
                var conversation = Conversation.conversationWithPeer(peer,
                    inManagedObjectContext: context)
                peer.conversation = conversation
                peer.setImageFromAddressBook()
                return peer
            }
    }
    
    class func peerWithNetID(aNetID: NetID,
        inManagedObjectContext context: NSManagedObjectContext) -> Peer {
            return peerWithIdentity(aNetID.identity,
                name: aNetID.name,
                inManagedObjectContext: context)
    }
    
    func setImageFromAddressBook() {
        if let email: NSString = NetID.emailFromIdentity(identity) {
            let c = CFIndex(kABEqualCaseInsensitive.value)
            
            let AB = ABAddressBook.sharedAddressBook()
            let personForEmail = ABPerson.searchElementForProperty(kABEmailProperty as String,
                label: nil,
                key: nil,
                value: email,
                comparison: c)
            if let peopleFound = AB.recordsMatchingSearchElement(personForEmail) as? [ABPerson] {
//                println(peopleFound.count)
                if let firstName = peopleFound[0].valueForProperty(kABFirstNameProperty) as? String {
                    self.name = firstName
                    if let lastName = peopleFound[0].valueForProperty(kABLastNameProperty) as? String {
                        self.name = self.name + " " + lastName
                    }
                }
                self.image = NSImage(data: peopleFound[0].imageData())
                self.circularImage = circularImageFromImage(self.image)
            }
        }
    }
    
    public override func awakeFromFetch() {
        self.available = false
        setImageFromAddressBook()
    }
}
