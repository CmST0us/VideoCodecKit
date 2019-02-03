//
//  VCFLVTag.m
//  VideoCodecKit
//
//  Created by CmST0us on 2019/1/30.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "VCFLVTag.h"
#import "VCByteArray.h"

#pragma mark - VCFLVTag
@interface VCFLVTag ()

@end

@implementation VCFLVTag
- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        _tagData = data;
    }
    return self;
}

- (uint32_t)dataSize {
    VCByteArray *array = [[VCByteArray alloc] initWithData:self.tagData];
    array.postion = 1;
    return [array readUInt24];
}

- (VCFLVTagType)tagType {
    VCByteArray *array = [[VCByteArray alloc] initWithData:self.tagData];
    array.postion = 0;
    return (VCFLVTagType)[array readUInt8];
}

- (uint32_t)timestamp {
    VCByteArray *array = [[VCByteArray alloc] initWithData:self.tagData];
    array.postion = 4;
    return [array readUInt24];
}

- (uint8_t)timestampExtended {
    VCByteArray *array = [[VCByteArray alloc] initWithData:self.tagData];
    array.postion = 7;
    return [array readUInt8];
}

- (uint32_t)streamID {
    VCByteArray *array = [[VCByteArray alloc] initWithData:self.tagData];
    array.postion = 8;
    return [array readUInt24];
}

- (NSData *)payloadData {
    return [self.tagData subdataWithRange:NSMakeRange(kVCFLVTagHeaderSize, self.tagData.length - kVCFLVTagHeaderSize)];
}

- (uint32_t)extendedTimeStamp {
    int32_t timestampExt = (int32_t)[self timestampExtended];
    int32_t timestamp = (int32_t)[self timestamp];
    timestamp = timestamp | (timestampExt << 24);
    return timestamp;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"\n[FLV][Tag]:\n\tdataSize: %d\n\ttimestamp: %d", [self dataSize], [self timestamp]];
}

@end

#pragma mark - VCFLVVideoTag
@implementation VCFLVVideoTag
- (VCFLVVideoTagFrameType)frameType {
    VCByteArray *array = [[VCByteArray alloc] initWithData:self.tagData];
    array.postion = kVCFLVTagHeaderSize;
    return (VCFLVVideoTagFrameType)(([array readUInt8] & 0xF0) >> 4);
}

- (VCFLVVideoTagEncodeID)encodeID {
    VCByteArray *array = [[VCByteArray alloc] initWithData:self.tagData];
    array.postion = kVCFLVTagHeaderSize;
    return (VCFLVVideoTagEncodeID)([array readUInt8] & 0x0F);
}

- (VCFLVVideoTagAVCPacketType)AVCPacketType {
    VCByteArray *array = [[VCByteArray alloc] initWithData:self.tagData];
    array.postion = kVCFLVTagHeaderSize + 1;
    return (VCFLVVideoTagAVCPacketType)[array readUInt8];
}

- (uint32_t)compositionTime {
    VCByteArray *array = [[VCByteArray alloc] initWithData:self.tagData];
    array.postion = kVCFLVTagHeaderSize + 2;
    return [array readUInt24];
}

- (NSData *)payloadData {
    NSUInteger offset = kVCFLVTagHeaderSize + kVCFLVVideoTagExternHeaderSize;
    return [self.tagData subdataWithRange:NSMakeRange(offset, self.tagData.length - offset)];
}

- (BOOL)isSupportCurrentFrameType {
    VCFLVVideoTagFrameType frameType = [self frameType];
    if (frameType == VCFLVVideoTagFrameTypeDisposableInterFrame ||
        frameType == VCFLVVideoTagFrameTypeGeneratedKeyFrame) {
        return NO;
    }
    return YES;
}

- (uint32_t)presentationTimeStamp {
    int32_t compositionTime = (int32_t)[self compositionTime];
    return self.extendedTimeStamp + compositionTime;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"\n[FLV][Video Tag]:\n\tdataSize:%d\n\tframeType: %d\n\tencodeID: %d\n\tAVCPacketType: %d\n\tcompositionTime: %d\n\ttimestamp: %d", [self dataSize], [self frameType], [self encodeID], [self AVCPacketType], [self compositionTime], [self timestamp]];
}
@end

#pragma mark - VCFLVAudioTag

@implementation VCFLVAudioTag
- (VCFLVAudioTagFormatType)formatType {
    VCByteArray *array = [[VCByteArray alloc] initWithData:self.tagData];
    array.postion = kVCFLVTagHeaderSize;
    return (VCFLVAudioTagFormatType)([array readUInt8] >> 4);
}

- (VCFLVAudioTagSampleRate)sampleRate {
    VCByteArray *array = [[VCByteArray alloc] initWithData:self.tagData];
    array.postion = kVCFLVTagHeaderSize;
    return (VCFLVAudioTagSampleRate)(([array readUInt8] >> 2) & 0x03);
}

- (VCFLVAudioTagSampleLength)sampleLength {
    VCByteArray *array = [[VCByteArray alloc] initWithData:self.tagData];
    array.postion = kVCFLVTagHeaderSize;
    return (VCFLVAudioTagSampleLength)(([array readUInt8] >> 1) & 0x01);
}

- (VCFLVAudioTagAudioType)audioType {
    VCByteArray *array = [[VCByteArray alloc] initWithData:self.tagData];
    array.postion = kVCFLVTagHeaderSize;
    return (VCFLVAudioTagAudioType)([array readUInt8] & 0x01);
}

- (VCFLVAudioTagAACPacketType)AACPacketType {
    VCByteArray *array = [[VCByteArray alloc] initWithData:self.tagData];
    array.postion = kVCFLVTagHeaderSize + 1;
    return (VCFLVAudioTagAACPacketType)[array readUInt8];
}

- (NSData *)payloadData {
    NSUInteger offset = kVCFLVTagHeaderSize + kVCFLVAudioTagExternHeaderSize;
    return [self.tagData subdataWithRange:NSMakeRange(offset, self.tagData.length - offset)];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"\n[FLV][Audio Tag]:\n\tdataSize:%d\n\tformatType: %d\n\tsampleRate: %d\n\tsampleLength: %d\n\taudioType: %d\n\tAACPacketType: %d\n\ttimestamp: %d", self.dataSize, self.formatType, self.sampleRate, self.sampleLength, self.audioType, self.AACPacketType, self.timestamp];
}
            
@end

#pragma mark - VCFLVMetaTag

@implementation VCFLVMetaTag

@end
