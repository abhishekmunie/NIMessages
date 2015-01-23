//
//  Conversation.h
//  NIMessages
//
//  Created by Abhishek Munie on 14/11/14.
//  Copyright (c) 2014 Abhishek Munie. All rights reserved.
//

@import Cocoa;

@class Message, Peer;

@interface Conversation : NSManagedObject

@property (nonatomic, retain) NSNumber * available;
@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) Peer *peer;
@end

@interface Conversation (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(Message *)value;
- (void)removeMessagesObject:(Message *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

@end
