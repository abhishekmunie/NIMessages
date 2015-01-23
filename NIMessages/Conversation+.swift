//
//  Conversation+.swift
//  NIMessagesSimple
//
//  Created by Abhishek Munie on 23/09/14.
//  Copyright (c) 2014 Abhishek Munie. All rights reserved.
//

import Foundation
import CoreData

private let _entityName = "Conversation"

//extension Conversation {
//    
//    func addMessagesObject(message: Message) {
//        self.mutableSetValueForKey("message").addObject(message)
//    }
//    
//    func removeMessagesObject(message: Message) {
//        self.mutableSetValueForKey("message").removeObject(message)
//    }
//    
//    func addMessages(values: NSSet) {
//        self.mutableSetValueForKey("message").unionSet(values)
//    }
//    
//    func removeMessages(values: NSSet) {
//        self.mutableSetValueForKey("message").minusSet(values)
//    }
//    
//}

extension Conversation {
    
    class var entityName: String { return _entityName }
    
    class func insertNewConversationInManagedObjectContext(context: NSManagedObjectContext) -> Conversation {
        return NSEntityDescription.insertNewObjectForEntityForName(self.entityName,
            inManagedObjectContext: context) as Conversation
    }
    
    //
    //    class func fetchPeerWithIdentity(,
    //        inManagedObjectContext context: NSManagedObjectContext) -> Conversation? {
    //            var request = NSFetchRequest()
    //            var entity = NSEntityDescription.entityForName(self.entityName,
    //                inManagedObjectContext: context)
    //            request.entity = entity
    //
    //            var predicate = NSPredicate(format:)
    //            request.predicate = predicate
    //            request.fetchLimit = 1
    //
    //            var error: NSError?
    //            var possibleObjects = context.executeFetchRequest(request, error:&error)
    //            if let objects = possibleObjects {
    //                var count = objects.count // May be 0 if the object has been deleted.
    //                if count != 0 {
    //                    return (objects[0] as Message)
    //                } else {
    //                    return nil
    //                }
    //            } else {
    //                // Deal with error.
    //                #if DEBUG
    //                    println("\(self.entityName) Fetch Failed for <\()>: \(error.localizedDescription)\n\(error.userInfo)")
    //                #endif
    //                return nil
    //            }
    //    }
    
    class func conversationWithPeer(peer: Peer,
        inManagedObjectContext context: NSManagedObjectContext) -> Conversation {
            var conversation = insertNewConversationInManagedObjectContext(context)
            conversation.peer = peer
            return conversation
    }
    
    override public func awakeFromFetch() {
        self.available = false
    }
    
    func createSampleMessages(n: Int) {
        for i in 0..<n {
            Message.messageWithText("Hello!",
                date: NSDate(),
                sender: (i%2==0) ? self.peer : MyPeerObject,
                conversation: self,
                inManagedObjectContext: ManagedObjectContext)
        }
    }
}

