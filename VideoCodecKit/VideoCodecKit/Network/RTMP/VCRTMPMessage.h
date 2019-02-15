//
//  VCRTMPMessage.h
//  VideoCodecKit
//
//  Created by CmST0us on 2019/2/12.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(uint8_t, VCRTMPMessageType) {
    // 5.4.  Protocol Control Messages
    VCRTMPMessageTypeSetChunkSize = 1,
    VCRTMPMessageTypeAbortMessage = 2,
    VCRTMPMessageTypeAcknowledgement = 3,
    VCRTMPMessageTypeWindowAcknowledgement = 5,
    VCRTMPMessageTypeUserControl = 4,
    VCRTMPMessageTypeSetPeerBandwidth = 6,
    
    // 7.1.  Types of Messages
    VCRTMPMessageTypeAMF0Command = 20,
    VCRTMPMessageTypeAMF3Command = 17,
    VCRTMPMessageTypeAMF0Data = 18,
    VCRTMPMessageTypeAMF3Data = 15,
    VCRTMPMessageTypeAMF0SharedObject = 19,
    VCRTMPMessageTypeAMF3SharedObject = 16,
    VCRTMPMessageTypeAudio = 8,
    VCRTMPMessageTypeVideo = 9,
    VCRTMPMessageTypeAggregate = 22,
    
    VCRTMPMessageTypeUnknow = 0xFF,
};
@interface VCRTMPMessage : NSObject
@property (nonatomic, assign) uint32_t timestamp;
@property (nonatomic, assign) uint32_t messageLength;
@property (nonatomic, assign) VCRTMPMessageType messageTypeID;
@property (nonatomic, assign) uint32_t messageStreamID;
@end

NS_ASSUME_NONNULL_END
