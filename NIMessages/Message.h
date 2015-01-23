//
//  Message.h
//  NIMessages
//
//  Created by Abhishek Munie on 14/11/14.
//  Copyright (c) 2014 Abhishek Munie. All rights reserved.
//

@import Cocoa;

@class Conversation, Peer;

@interface Message : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSDate * delivered;
@property (nonatomic, retain) NSData * extensions;
@property (nonatomic, retain) NSDate * read;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) Conversation *conversation;
@property (nonatomic, retain) Peer *sender;

@end
