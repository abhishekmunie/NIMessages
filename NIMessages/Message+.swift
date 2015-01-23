//
//  Message+.swift
//  NIMessagesSimple
//
//  Created by Abhishek Munie on 23/09/14.
//  Copyright (c) 2014 Abhishek Munie. All rights reserved.
//

import Foundation
import CoreData

private let _entityName = "Message"

extension Message {
    
    class var entityName: String { return _entityName }

    
    class func insertNewMessageInManagedObjectContext(context: NSManagedObjectContext) -> Message {
        return NSEntityDescription.insertNewObjectForEntityForName(self.entityName,
            inManagedObjectContext: context) as Message
    }
//
//    class func fetchPeerWithIdentity(,
//        inManagedObjectContext context: NSManagedObjectContext) -> Message? {
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
    
    class func messageWithText(text: String,
        date: NSDate,
        sender: Peer,
        conversation: Conversation,
        inManagedObjectContext context: NSManagedObjectContext) -> Message {
            var message = insertNewMessageInManagedObjectContext(context)
            message.text = text
            message.date = date
            message.sender = sender
            message.conversation = conversation
            
            conversation.addMessagesObject(message)
            return message
    }

}
