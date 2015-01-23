//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//
#import <CommonCrypto/CommonCrypto.h>

#import "Peer.h"
#import "Conversation.h"
#import "Message.h"

typedef NS_ENUM(NSUInteger, MessageBubbleType) {
    MessageBubbleTypeLeft = 0,
    MessageBubbleTypeRight
};
