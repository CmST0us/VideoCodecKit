//
//  VCAudioFrameParser+AudioFileStreamPropertyParser.m
//  VideoCodecKit
//
//  Created by CmST0us on 2018/11/8.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import "VCAudioFrameParser+AudioFileStreamPropertyParser.h"

#define PROPERTY_PARSER_MAP_KEY_VALUE(k, v) @(k): @(sizeof(v))

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
