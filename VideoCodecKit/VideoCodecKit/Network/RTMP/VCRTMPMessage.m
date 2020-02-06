//
//  VCRTMPMessage.m
//  VideoCodecKit
//
//  Created by CmST0us on 2019/2/12.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "VCRTMPMessage.h"

#define kVCRTMPMessageDefaultStreamID (10)

@implementation VCRTMPMessage
- (instancetype)init {
    self = [super init];
    if (self) {
        _timestamp = 0;
        _messageLength = 0;
        _messageTypeID = 0;
        _messageStreamID = kVCRTMPMessageDefaultStreamID;
    }
    return self;
}

- (instancetype)copyWithZone:(nullable NSZone *)zone {
    VCRTMPMessage *message = [[VCRTMPMessage alloc] init];
    message.timestamp = self.timestamp;
    message.messageLength = self.messageLength;
    message.messageTypeID = self.messageTypeID;
    message.messageStreamID = self.messageStreamID;
    return message;
}
- (NSString *)description {
    return [NSString stringWithFormat:@"{messageTypeID: %d, messageStreamID: %d}", self.messageTypeID, self.messageStreamID];
}
@end
