//
//  VCAudioFrameParser+AudioFileStreamPropertyParser.m
//  VideoCodecKit
//
//  Created by CmST0us on 2018/11/8.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import "VCAudioFrameParser+AudioFileStreamPropertyParser.h"

#define RET_DEFAULT_VALUE(t) t d = {0};return d;
#define GET_PROPERTY_RAW_DATA(k) self.userInfo[@(k)]
#define RET_PROPERTY(t, s) \
t p;\
memcpy(&p, s, sizeof(p));\
return p;

#define PROPERTY_PARSER_MAP_KEY_VALUE(k, v) @(k): @(sizeof(v))

@implementation VCAudioFrame (AudioFileStreamProperty)
- (UInt32)readyToProducePackets {
    NSData *raw = GET_PROPERTY_RAW_DATA(kAudioFileStreamProperty_ReadyToProducePackets);
    if (raw == nil) {RET_DEFAULT_VALUE(UInt32);}
    
    RET_PROPERTY(UInt32, raw.bytes);
}

- (AudioStreamBasicDescription)dataFormat {
    NSData *raw = GET_PROPERTY_RAW_DATA(kAudioFileStreamProperty_DataFormat);
    if (raw == nil) {RET_DEFAULT_VALUE(AudioStreamBasicDescription);}
    
    RET_PROPERTY(AudioStreamBasicDescription, raw.bytes);
}

- (AudioFormatListItem)formatList {
    NSData *raw = GET_PROPERTY_RAW_DATA(kAudioFileStreamProperty_FormatList);
    if (raw == nil) {RET_DEFAULT_VALUE(AudioFormatListItem);}
    
    RET_PROPERTY(AudioFormatListItem, raw.bytes);
}

- (void *)magicCookieData {
    NSData *raw = GET_PROPERTY_RAW_DATA(kAudioFileStreamProperty_MagicCookieData);
    if (raw == nil) {RET_DEFAULT_VALUE(void *);}
    
    RET_PROPERTY(void *, raw.bytes);
}

- (UInt64)audioDataByteCount {
    NSData *raw = GET_PROPERTY_RAW_DATA(kAudioFileStreamProperty_AudioDataByteCount);
    if (raw == nil) {RET_DEFAULT_VALUE(UInt64);}
    
    RET_PROPERTY(UInt64, raw.bytes);
}

- (UInt64)audioDataPacketCount {
    NSData *raw = GET_PROPERTY_RAW_DATA(kAudioFileStreamProperty_AudioDataPacketCount);
    if (raw == nil) {RET_DEFAULT_VALUE(UInt64);}
    
    RET_PROPERTY(UInt32, raw.bytes);
}

- (UInt32)maximumPacketSize {
    NSData *raw = GET_PROPERTY_RAW_DATA(kAudioFileStreamProperty_MaximumPacketSize);
    if (raw == nil) {RET_DEFAULT_VALUE(UInt32);}
    
    RET_PROPERTY(UInt32, raw.bytes);
}

- (SInt64)dataOffset {
    NSData *raw = GET_PROPERTY_RAW_DATA(kAudioFileStreamProperty_DataOffset);
    if (raw == nil) {RET_DEFAULT_VALUE(SInt64);}
    
    RET_PROPERTY(SInt64, raw.bytes);
}

- (AudioChannelLayout)channelLayout {
    NSData *raw = GET_PROPERTY_RAW_DATA(kAudioFileStreamProperty_ChannelLayout);
    if (raw == nil) {RET_DEFAULT_VALUE(AudioChannelLayout);}
    
    RET_PROPERTY(AudioChannelLayout, raw.bytes);
}

- (AudioFramePacketTranslation)packetToFrame {
    NSData *raw = GET_PROPERTY_RAW_DATA(kAudioFileStreamProperty_PacketToFrame);
    if (raw == nil) {RET_DEFAULT_VALUE(AudioFramePacketTranslation);}
    
    RET_PROPERTY(AudioFramePacketTranslation, raw.bytes);
}

- (AudioFramePacketTranslation)frameToPacket {
    NSData *raw = GET_PROPERTY_RAW_DATA(kAudioFileStreamProperty_FrameToPacket);
    if (raw == nil) {RET_DEFAULT_VALUE(AudioFramePacketTranslation);}
    
    RET_PROPERTY(AudioFramePacketTranslation, raw.bytes);
}

- (AudioFramePacketTranslation)packetToByte {
    NSData *raw = GET_PROPERTY_RAW_DATA(kAudioFileStreamProperty_PacketToByte);
    if (raw == nil) {RET_DEFAULT_VALUE(AudioFramePacketTranslation);}
    
    RET_PROPERTY(AudioFramePacketTranslation, raw.bytes);
}

- (AudioFramePacketTranslation)byteToPacket {
    NSData *raw = GET_PROPERTY_RAW_DATA(kAudioFileStreamProperty_ByteToPacket);
    if (raw == nil) {RET_DEFAULT_VALUE(AudioFramePacketTranslation);}
    
    RET_PROPERTY(AudioFramePacketTranslation, raw.bytes);
}

- (AudioFilePacketTableInfo)packetTableInfo {
    NSData *raw = GET_PROPERTY_RAW_DATA(kAudioFileStreamProperty_PacketTableInfo);
    if (raw == nil) {RET_DEFAULT_VALUE(AudioFilePacketTableInfo);}
    
    RET_PROPERTY(AudioFilePacketTableInfo, raw.bytes);
}

- (UInt32)packetSizeUpperBound {
    NSData *raw = GET_PROPERTY_RAW_DATA(kAudioFileStreamProperty_PacketSizeUpperBound);
    if (raw == nil) {RET_DEFAULT_VALUE(UInt32);}
    
    RET_PROPERTY(UInt32, raw.bytes);
}

- (Float64)averageBytesPerPacket {
    NSData *raw = GET_PROPERTY_RAW_DATA(kAudioFileStreamProperty_AverageBytesPerPacket);
    if (raw == nil) {RET_DEFAULT_VALUE(Float64);}
    
    RET_PROPERTY(UInt32, raw.bytes);
}

- (UInt32)bitRate {
    NSData *raw = GET_PROPERTY_RAW_DATA(kAudioFileStreamProperty_BitRate);
    if (raw == nil) {RET_DEFAULT_VALUE(UInt32);}
    
    RET_PROPERTY(UInt32, raw.bytes);
}

- (CFDictionaryRef)infoDictionary {
    NSData *raw = GET_PROPERTY_RAW_DATA(kAudioFileStreamProperty_InfoDictionary);
    if (raw == nil) {RET_DEFAULT_VALUE(CFDictionaryRef);}
    
    RET_PROPERTY(CFDictionaryRef, raw.bytes);
}

@end

@implementation VCAudioFrameParser (AudioFileStreamPropertyParser)
+ (NSDictionary *)propertyParserMap {
    return  @{
             PROPERTY_PARSER_MAP_KEY_VALUE(kAudioFileStreamProperty_ReadyToProducePackets, UInt32),
             PROPERTY_PARSER_MAP_KEY_VALUE(kAudioFileStreamProperty_FileFormat, UInt32),
             PROPERTY_PARSER_MAP_KEY_VALUE(kAudioFileStreamProperty_DataFormat, AudioStreamBasicDescription),
             PROPERTY_PARSER_MAP_KEY_VALUE(kAudioFileStreamProperty_FormatList, AudioFormatListItem),
             PROPERTY_PARSER_MAP_KEY_VALUE(kAudioFileStreamProperty_MagicCookieData, void *),
             PROPERTY_PARSER_MAP_KEY_VALUE(kAudioFileStreamProperty_AudioDataByteCount, UInt64),
             PROPERTY_PARSER_MAP_KEY_VALUE(kAudioFileStreamProperty_AudioDataPacketCount, UInt64),
             PROPERTY_PARSER_MAP_KEY_VALUE(kAudioFileStreamProperty_MaximumPacketSize, UInt32),
             PROPERTY_PARSER_MAP_KEY_VALUE(kAudioFileStreamProperty_DataOffset, SInt64),
             PROPERTY_PARSER_MAP_KEY_VALUE(kAudioFileStreamProperty_ChannelLayout, AudioChannelLayout),
             PROPERTY_PARSER_MAP_KEY_VALUE(kAudioFileStreamProperty_PacketToFrame, AudioFramePacketTranslation),
             PROPERTY_PARSER_MAP_KEY_VALUE(kAudioFileStreamProperty_FrameToPacket, AudioFramePacketTranslation),
             PROPERTY_PARSER_MAP_KEY_VALUE(kAudioFileStreamProperty_PacketToByte, AudioBytePacketTranslation),
             PROPERTY_PARSER_MAP_KEY_VALUE(kAudioFileStreamProperty_ByteToPacket, AudioBytePacketTranslation),
             PROPERTY_PARSER_MAP_KEY_VALUE(kAudioFileStreamProperty_PacketTableInfo, AudioFilePacketTableInfo),
             PROPERTY_PARSER_MAP_KEY_VALUE(kAudioFileStreamProperty_PacketSizeUpperBound, UInt32),
             PROPERTY_PARSER_MAP_KEY_VALUE(kAudioFileStreamProperty_AverageBytesPerPacket, Float64),
             PROPERTY_PARSER_MAP_KEY_VALUE(kAudioFileStreamProperty_BitRate, UInt32),
             PROPERTY_PARSER_MAP_KEY_VALUE(kAudioFileStreamProperty_InfoDictionary, CFDictionaryRef),
         };
}

+ (void)getAudioFileStreamProperty:(AudioFilePropertyID)propertyID
                          streamID:(AudioFileStreamID)streamID
                   addToDictionary:(NSMutableDictionary *)dict {
    NSDictionary *map = [VCAudioFrameParser propertyParserMap];
    NSNumber *sizeNumber = map[@(propertyID)];
    if (sizeNumber == nil) return;
    UInt32 propertySize = (UInt32)[sizeNumber unsignedIntegerValue];
    void *propertyData = malloc(propertySize);
    memset(propertyData, 0, propertySize);
    
    OSStatus ret = AudioFileStreamGetProperty(streamID, propertyID, &propertySize, propertyData);
    if (ret != noErr) {
        free(propertyData);
        return;
    }

    NSData *data = [[NSData alloc] initWithBytes:propertyData length:propertySize];
    [dict setObject:data forKey:@(propertyID)];
    free(propertyData);
}

@end
