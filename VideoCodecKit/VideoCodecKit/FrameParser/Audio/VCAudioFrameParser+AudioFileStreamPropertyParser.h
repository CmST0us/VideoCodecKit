//
//  VCAudioFrameParser+AudioFileStreamPropertyParser.h
//  VideoCodecKit
//
//  Created by CmST0us on 2018/11/8.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import "VCAudioFrameParser.h"
#import "VCAudioFrame.h"

@interface VCAudioFrame (AudioFileStreamProperty)
@property (nonatomic, assign, readonly) UInt32 readyToProducePackets;
@property (nonatomic, assign, readonly) AudioStreamBasicDescription dataFormat;
@property (nonatomic, assign, readonly) AudioFormatListItem formatList;
@property (nonatomic, assign, readonly) void *magicCookieData;
@property (nonatomic, assign, readonly) UInt64 audioDataByteCount;
@property (nonatomic, assign, readonly) UInt64 audioDataPacketCount;
@property (nonatomic, assign, readonly) UInt32 maximumPacketSize;
@property (nonatomic, assign, readonly) SInt64 dataOffset;
@property (nonatomic, assign, readonly) AudioChannelLayout channelLayout;
@property (nonatomic, assign, readonly) AudioFramePacketTranslation packetToFrame;
@property (nonatomic, assign, readonly) AudioFramePacketTranslation frameToPacket;
@property (nonatomic, assign, readonly) AudioFramePacketTranslation packetToByte;
@property (nonatomic, assign, readonly) AudioFramePacketTranslation byteToPacket;
@property (nonatomic, assign, readonly) AudioFilePacketTableInfo packetTableInfo;
@property (nonatomic, assign, readonly) UInt32 packetSizeUpperBound;
@property (nonatomic, assign, readonly) Float64 averageBytesPerPacket;
@property (nonatomic, assign, readonly) UInt32 bitRate;
@property (nonatomic, assign, readonly) CFDictionaryRef infoDictionary;
@end


@interface VCAudioFrameParser (AudioFileStreamPropertyParser)
+ (void)getAudioFileStreamProperty:(AudioFilePropertyID)propertyID
                          streamID:(AudioFileStreamID)streamID
                   addToDictionary:(NSMutableDictionary *)dict;
@end
