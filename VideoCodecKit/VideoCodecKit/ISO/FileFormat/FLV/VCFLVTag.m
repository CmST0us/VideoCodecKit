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
@interface VCFLVTag () {
@protected
    NSData *_tagData;
}
@property (nonatomic, readonly) NSData *tagData;
@end

@implementation VCFLVTag

+ (instancetype)tag {
    VCFLVTag *tag = [[VCFLVTag alloc] init];
    tag.tagType = VCFLVTagTypeMeta;
    tag.timestamp = 0;
    tag.timestampExtended = 0;
    tag.streamID = 0;
    return tag;
}

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        _tagData = data;
    }
    return self;
}

- (NSData *)payloadDataWithoutExternTimestamp {
    NSUInteger offset = kVCFLVTagHeaderSize;
    return [self.tagData subdataWithRange:NSMakeRange(offset, self.tagData.length - offset)];
}

- (uint32_t)extendedTimeStamp {
    int32_t timestampExt = (int32_t)self.timestampExtended;
    int32_t timestamp = (int32_t)self.timestamp;
    timestamp = timestamp | (timestampExt << 24);
    return timestamp;
}

- (void)setPayloadData:(NSData *)payloadData {
    _payloadData = payloadData;
    self.dataSize = (uint32_t)payloadData.length;
}

- (NSData *)serialize {
    VCByteArray *array = [[VCByteArray alloc] init];
    [array writing:^(VCByteArrayWriter * _Nonnull writer) {
        writer.writeUInt8(self.tagType)
        .writeUInt24(self.dataSize)
        .writeUInt24(self.timestamp)
        .writeUInt8(self.timestampExtended)
        .writeUInt24(self.streamID)
        .writeBytes(self.payloadData);
    }];
    _tagData = array.data;
    return _tagData;
}

- (void)deserialize {
    VCByteArray *array = [[VCByteArray alloc] initWithData:self.tagData];
    self.tagType = [array readUInt8];
    self.dataSize = [array readUInt24];
    self.timestamp = [array readUInt24];
    self.timestampExtended = [array readUInt8];
    self.streamID = [array readUInt24];
    self.payloadData = [array readBytes:self.dataSize];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"\n[FLV][Tag]:\n\tdataSize: %d\n\ttimestamp: %d", [self dataSize], [self timestamp]];
}

@end

#pragma mark - VCFLVVideoTag
@implementation VCFLVVideoTag
+ (instancetype)sequenceHeaderTagForAVC {
    VCFLVVideoTag *tag = [VCFLVVideoTag tag];
    tag.frameType = VCFLVVideoTagFrameTypeKeyFrame;
    tag.encodeID = VCFLVVideoTagEncodeIDAVC;
    tag.AVCPacketType = VCFLVVideoTagAVCPacketTypeSequenceHeader;
    return tag;
}

+ (instancetype)tagForAVC {
    VCFLVVideoTag *tag = [VCFLVVideoTag tag];
    tag.encodeID = VCFLVVideoTagEncodeIDAVC;
    tag.AVCPacketType = VCFLVVideoTagAVCPacketTypeNALU;
    return tag;
}

+ (instancetype)tag {
    VCFLVVideoTag *tag = [[VCFLVVideoTag alloc] init];
    tag.tagType = VCFLVTagTypeVideo;
    tag.timestamp = 0;
    tag.timestampExtended = 0;
    tag.streamID = 0;
    return tag;
}

- (void)setPayloadData:(NSData *)payloadData {
    [super setPayloadData:payloadData];
    self.dataSize = (uint32_t)(payloadData.length + kVCFLVVideoTagExternHeaderSize);
}

- (BOOL)isSupportCurrentFrameType {
    VCFLVVideoTagFrameType frameType = self.frameType;
    if (frameType == VCFLVVideoTagFrameTypeDisposableInterFrame ||
        frameType == VCFLVVideoTagFrameTypeGeneratedKeyFrame) {
        return NO;
    }
    return YES;
}

- (uint32_t)presentationTimeStamp {
    int32_t compositionTime = (int32_t)self.compositionTime;
    return self.extendedTimeStamp + compositionTime;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"\n[FLV][Video Tag]:\n\tdataSize:%d\n\tframeType: %d\n\tencodeID: %d\n\tAVCPacketType: %d\n\tcompositionTime: %d\n\ttimestamp: %d", [self dataSize], [self frameType], [self encodeID], [self AVCPacketType], [self compositionTime], [self timestamp]];
}

- (NSData *)serialize {
    VCByteArray *array = [[VCByteArray alloc] init];
    [array writing:^(VCByteArrayWriter * _Nonnull writer) {
        writer.writeUInt8(self.tagType)
        .writeUInt24(self.dataSize)
        .writeUInt24(self.timestamp)
        .writeUInt8(self.timestampExtended)
        .writeUInt24(self.streamID)
        .writeUInt8(((self.frameType << 4) & 0xF0) | (self.encodeID & 0x0F))
        .writeUInt8(self.AVCPacketType)
        .writeUInt24(self.compositionTime)
        .writeBytes(self.payloadData);
    }];
    _tagData = array.data;
    return _tagData;
}

- (void)deserialize {
    VCByteArray *array = [[VCByteArray alloc] initWithData:self.tagData];
    self.tagType = [array readUInt8];
    self.dataSize = [array readUInt24];
    self.timestamp = [array readUInt24];
    self.timestampExtended = [array readUInt8];
    self.streamID = [array readUInt24];
    
    uint8_t frameTypeEncodeID = [array readUInt8];
    self.frameType = (frameTypeEncodeID & 0xF0) >> 4;
    self.encodeID = frameTypeEncodeID & 0x0F;
    self.AVCPacketType = [array readUInt8];
    self.compositionTime = [array readUInt24];
    self.payloadData = [array readBytes:self.dataSize - kVCFLVVideoTagExternHeaderSize];
}

@end

#pragma mark - VCFLVAudioTag

@implementation VCFLVAudioTag

+ (instancetype)sequenceHeaderTagForAAC {
    VCFLVAudioTag *tag= [VCFLVAudioTag tag];
    tag.formatType = VCFLVAudioTagFormatTypeAAC;
    tag.sampleRate = VCFLVAudioTagSampleRate44kHz;
    tag.sampleLength = VCFLVAudioTagSampleLength16Bit;
    tag.audioType = VCFLVAudioTagAudioTypeStereo;
    tag.AACPacketType = VCFLVAudioTagAACPacketTypeSequenceHeader;
    return tag;
}

+ (instancetype)tagForAAC {
    VCFLVAudioTag *tag= [VCFLVAudioTag tag];
    tag.formatType = VCFLVAudioTagFormatTypeAAC;
    tag.sampleRate = VCFLVAudioTagSampleRate44kHz;
    tag.sampleLength = VCFLVAudioTagSampleLength16Bit;
    tag.audioType = VCFLVAudioTagAudioTypeStereo;
    tag.AACPacketType = VCFLVAudioTagAACPacketTypeRaw;
    return tag;
}

+ (instancetype)tag {
    VCFLVAudioTag *tag = [[VCFLVAudioTag alloc] init];
    tag.tagType = VCFLVTagTypeAudio;
    tag.timestamp = 0;
    tag.timestampExtended = 0;
    tag.streamID = 0;
    return tag;
}

- (void)setPayloadData:(NSData *)payloadData {
    [super setPayloadData:payloadData];
    self.dataSize = (uint32_t)(payloadData.length + kVCFLVAudioTagExternHeaderSize);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"\n[FLV][Audio Tag]:\n\tdataSize:%d\n\tformatType: %d\n\tsampleRate: %d\n\tsampleLength: %d\n\taudioType: %d\n\tAACPacketType: %d\n\ttimestamp: %d", self.dataSize, self.formatType, self.sampleRate, self.sampleLength, self.audioType, self.AACPacketType, self.timestamp];
}

- (NSData *)serialize {
    VCByteArray *array = [[VCByteArray alloc] init];
    uint8_t firstByte = (self.audioType & 0x01) | ((self.sampleLength & 0x01) << 1) | ((self.sampleRate & 0x03) << 2) | ((self.formatType & 0x0F) << 4);
    [array writing:^(VCByteArrayWriter * _Nonnull writer) {
        writer.writeUInt8(self.tagType)
        .writeUInt24(self.dataSize)
        .writeUInt24(self.timestamp)
        .writeUInt8(self.timestampExtended)
        .writeUInt24(self.streamID)
        .writeUInt8(firstByte)
        .writeUInt8(self.AACPacketType)
        .writeBytes(self.payloadData);
    }];
    _tagData = array.data;
    return _tagData;
}

- (void)deserialize {
    VCByteArray *array = [[VCByteArray alloc] initWithData:self.tagData];
    self.tagType = [array readUInt8];
    self.dataSize = [array readUInt24];
    self.timestamp = [array readUInt24];
    self.timestampExtended = [array readUInt8];
    self.streamID = [array readUInt24];
    
    uint8_t firstByte = [array readUInt8];
    self.audioType = firstByte & 0x01;
    self.sampleLength = (firstByte >> 1) & 0x01;
    self.sampleRate = (firstByte >> 2) & 0x03;
    self.formatType = (firstByte >> 4) & 0x0F;
    self.AACPacketType = [array readUInt8];
    self.payloadData = [array readBytes:self.dataSize - kVCFLVAudioTagExternHeaderSize];
}
            
@end

#pragma mark - VCFLVMetaTag

@implementation VCFLVMetaTag

@end
