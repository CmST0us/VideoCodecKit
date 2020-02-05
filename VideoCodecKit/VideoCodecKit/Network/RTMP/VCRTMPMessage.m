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
        _timestamp = [[NSDate date] timeIntervalSince1970];
        _messageLength = 0;
        _messageTypeID = 0;
        _messageStreamID = kVCRTMPMessageDefaultStreamID;
    }
    return self;
}
@end
