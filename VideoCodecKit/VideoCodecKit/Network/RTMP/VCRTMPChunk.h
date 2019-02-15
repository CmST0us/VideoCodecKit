//
//  VCRTMPChunk.h
//  VideoCodecKit
//
//  Created by CmST0us on 2019/2/12.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// reference: Adobe’s Real Time Messaging Protocol
//            rtmp_specification_1.0.pdf

/*
 
 Chunk Format:
 
 +--------------+----------------+--------------------+--------------+
 | Basic Header | Message Header | Extended Timestamp | Chunk Data   |
 +--------------+----------------+--------------------+--------------+
 |                                                    |              |
 |<------------------- Chunk Header ----------------->|              |
 |<------------------------------ Chunk ---------------------------->|
 
 */

// seealso: 5.3.1.1.  Chunk Basic Header
typedef NS_ENUM(NSUInteger, VCRTMPChunkStreamID) {
    VCRTMPChunkStreamIDControl = 0x02,
    VCRTMPChunkStreamIDCommand = 0x03,
    VCRTMPChunkStreamIDAudio = 0x04,
    VCRTMPChunkStreamIDVideo = 0x05,
};


typedef NS_ENUM(uint8_t, VCRTMPChunkMessageHeaderType) {
    VCRTMPChunkMessageHeaderType0 = 0,
    VCRTMPChunkMessageHeaderType1 = 1,
    VCRTMPChunkMessageHeaderType2 = 2,
    VCRTMPChunkMessageHeaderType3 = 3,
};

@class VCRTMPMessage;
@interface VCRTMPChunk : NSObject

/**
 Use VCRTMPChunkStreamID when publish
 */
@property (nonatomic, assign) NSUInteger chunkStreamID;
@property (nonatomic, assign) VCRTMPChunkMessageHeaderType messageHeaderType;
@property (nonatomic, assign) VCRTMPMessage *message;

- (instancetype)initWithType:(VCRTMPChunkMessageHeaderType)type
               chunkStreamID:(NSUInteger)chunkStreamID
                     message:(VCRTMPMessage *)message;

- (instancetype)initWithData:(NSData *)data;

- (NSData *)makeBasicHeader;
- (NSData *)makeMessageHeaderWithExtendedTimestamp;
- (NSData *)makeChunkHeader;

@end

NS_ASSUME_NONNULL_END
