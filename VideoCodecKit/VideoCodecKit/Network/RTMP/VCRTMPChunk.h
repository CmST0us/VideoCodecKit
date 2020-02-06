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
typedef NS_ENUM(uint32_t, VCRTMPChunkStreamID) {
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
@property (nonatomic, assign) VCRTMPChunkStreamID chunkStreamID;
@property (nonatomic, assign) VCRTMPChunkMessageHeaderType messageHeaderType;
@property (nonatomic, strong, nullable) VCRTMPMessage *message;
@property (nonatomic, strong, nullable) NSData *chunkData;

- (instancetype)initWithType:(VCRTMPChunkMessageHeaderType)type
               chunkStreamID:(VCRTMPChunkStreamID)chunkStreamID
                     message:(VCRTMPMessage *)message;

- (NSInteger)basicHeaderSize;
- (NSInteger)messageHeaderSize;
- (NSInteger)extendedTimestampSize;

- (NSData *)makeBasicHeader;
- (NSData *)makeMessageHeaderWithExtendedTimestamp;
- (NSData *)makeChunkHeader;
- (NSData *)makeChunk;

@end

@interface VCRTMPChunk (ProtocolControlMessage)
+ (instancetype)makeSetChunkSize:(uint32_t)size;
- (uint32_t)setChunkSizeValue;

+ (instancetype)makeAbortMessage:(uint32_t)chunkStreamID;
- (uint32_t)abortMessageValue;

+ (instancetype)makeAcknowledgement:(uint32_t)seq;
- (uint32_t)acknowledgementValue;

+ (instancetype)makeWindowAcknowledgementSize:(uint32_t)windowSize;
- (uint32_t)windowAcknowledgementSizeValue;

+ (instancetype)makeSetPeerBandwidth:(uint32_t)ackWindowSize
                           limitType:(uint8_t)limitType;
- (uint32_t)setPeerBandwidthValue;
- (uint8_t)limitTypeValue;
@end

NS_ASSUME_NONNULL_END
