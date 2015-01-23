//
//  Peer.h
//  NIMessages
//
//  Created by Abhishek Munie on 14/11/14.
//  Copyright (c) 2014 Abhishek Munie. All rights reserved.
//

@import Cocoa;

@class Conversation, Message;

@interface Peer : NSManagedObject

@property (nonatomic, retain) NSNumber * available;
@property (nonatomic, retain) NSImage * circularImage;
@property (nonatomic, retain) NSString * identity;
@property (nonatomic, retain) NSImage * image;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Conversation *conversation;
@property (nonatomic, retain) NSSet *sentMessages;
@end

@interface Peer (CoreDataGeneratedAccessors)

- (void)addSentMessagesObject:(Message *)value;
- (void)removeSentMessagesObject:(Message *)value;
- (void)addSentMessages:(NSSet *)values;
- (void)removeSentMessages:(NSSet *)values;

@end
