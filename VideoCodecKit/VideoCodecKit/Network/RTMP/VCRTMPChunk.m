//
//  VCRTMPChunk.m
//  VideoCodecKit
//
//  Created by CmST0us on 2019/2/12.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "VCByteArray.h"
#import "VCRTMPChunk.h"
#import "VCRTMPMessage.h"

@interface VCRTMPChunk ()

@end

@implementation VCRTMPChunk

- (instancetype)initWithType:(VCRTMPChunkMessageHeaderType)type
               chunkStreamID:(VCRTMPChunkStreamID)chunkStreamID
                     message:(VCRTMPMessage *)message {
    self = [super init];
    if (self) {
        _messageHeaderType = type;
        _chunkStreamID = chunkStreamID;
        _message = message;
    }
    return self;
}

- (NSInteger)basicHeaderSize {
    if (self.chunkStreamID <= 63) {
        return 1;
    } else if (self.chunkStreamID <= 319) {
        return 2;
    } else {
        return 3;
    }
}

- (NSInteger)messageHeaderSize {
    if (self.messageHeaderType == VCRTMPChunkMessageHeaderType0) {
        return 11;
    } else if (self.messageHeaderType == VCRTMPChunkMessageHeaderType1) {
        return 7;
    } else if (self.messageHeaderType == VCRTMPChunkMessageHeaderType2) {
        return 3;
    } else {
        return 0;
    }
}

- (NSInteger)extendedTimestampSize {
    if (self.message &&
        self.message.timestamp >= 0xFFFFFF) {
        return 4;
    }
    return 0;
}

- (void)setChunkData:(NSData *)chunkData {
    _chunkData = chunkData;
    if (self.message) {
        self.message.messageLength = (uint32_t)chunkData.length;
    }
}

- (NSData *)makeBasicHeader {
    NSInteger basicHeaderLen = [self basicHeaderSize];
    uint8_t header[3] = {0};
    if (basicHeaderLen == 1) {
        header[0] = (self.messageHeaderType << 6) | (self.chunkStreamID);
        return [[NSData alloc] initWithBytes:header length:basicHeaderLen];
    } else if (basicHeaderLen == 2) {
        header[0] = (self.messageHeaderType << 6) & 0xC0;
        header[1] = (self.chunkStreamID - 64) & 0xFF;
        return [[NSData alloc] initWithBytes:header length:basicHeaderLen];
    } else {
        header[0] = (self.messageHeaderType << 6) | 0x3F;
        NSInteger rawChunkStreamID = CFSwapInt16HostToLittle(self.chunkStreamID - 64);
        memcpy(header + 1, &rawChunkStreamID, 2);
        return [[NSData alloc] initWithBytes:header length:basicHeaderLen];
    }
}

- (NSData *)makeMessageHeaderWithExtendedTimestamp {
    // Type 3
    if ([self messageHeaderType] == VCRTMPChunkMessageHeaderType3) {
        return [NSData data];
    } else {
        VCByteArray *array = [[VCByteArray alloc] init];
        if (self.message.timestamp >= 0xFFFFFF) {
            [array writeUInt24:0xFFFFFF];
        } else {
            [array writeUInt24:self.message.timestamp];
        }
        
        // Type 2
        if ([self messageHeaderType] == VCRTMPChunkMessageHeaderType2) {
            if (self.message.timestamp >= 0xFFFFFF) {
                [array writeUInt32:self.message.timestamp];
            }
            return array.data;
        }
        
        // Type 1
        [array writeUInt24:self.message.messageLength];
        [array writeUInt8:self.message.messageTypeID];
        if ([self messageHeaderType] == VCRTMPChunkMessageHeaderType1) {
            if (self.message.timestamp >= 0xFFFFFF) {
                [array writeUInt32:self.message.timestamp];
            }
            return array.data;
        }
        
        // Type 0
        uint32_t swapStreamID = CFSwapInt32HostToLittle(self.message.messageStreamID);
        [array writeUInt32:swapStreamID];
        if (self.message.timestamp >= 0xFFFFFF) {
            [array writeUInt32:self.message.timestamp];
        }
        return array.data;
    }
}

- (NSData *)makeChunkHeader {
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self makeBasicHeader]];
    [data appendData:[self makeMessageHeaderWithExtendedTimestamp]];
    return data;
}

- (NSData *)makeChunk {
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self makeChunkHeader]];
    [data appendData:self.chunkData];
    return data;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Chunk: {\n\tmessageHeaderType: %d,\n\tchunkStreamID: %d,\n\tmessage: %@,\n\tchunkData: %@\n}", self.messageHeaderType, self.chunkStreamID, self.message, self.chunkData.debugDescription];
}
@end

@implementation VCRTMPChunk (ProtocolControlMessage)

+ (instancetype)makeSetChunkSize:(uint32_t)size {
    VCRTMPMessage *message = [[VCRTMPMessage alloc] init];
    message.messageTypeID = VCRTMPMessageTypeSetChunkSize;
    VCRTMPChunk *chunk = [[VCRTMPChunk alloc] initWithType:VCRTMPChunkMessageHeaderType0 chunkStreamID:VCRTMPChunkStreamIDControl message:message];
    VCByteArray *arr = [[VCByteArray alloc] init];
    [arr writeUInt32:size];
    chunk.chunkData = arr.data;
    return chunk;
}
- (uint32_t)setChunkSizeValue {
    if (self.message.messageTypeID == VCRTMPMessageTypeSetChunkSize) {
        VCByteArray *arr = [[VCByteArray alloc] initWithData:self.chunkData];
        return [arr readUInt32];
    }
    return 0;
}

+ (instancetype)makeAbortMessage:(uint32_t)chunkStreamID {
    VCRTMPMessage *message = [[VCRTMPMessage alloc] init];
    message.messageTypeID = VCRTMPMessageTypeAbortMessage;
    VCRTMPChunk *chunk = [[VCRTMPChunk alloc] initWithType:VCRTMPChunkMessageHeaderType0 chunkStreamID:VCRTMPChunkStreamIDControl message:message];
    VCByteArray *arr = [[VCByteArray alloc] init];
    [arr writeUInt32:chunkStreamID];
    chunk.chunkData = arr.data;
    return chunk;
}

- (uint32_t)abortMessageValue {
    if (self.message.messageTypeID == VCRTMPMessageTypeAbortMessage) {
        VCByteArray *arr = [[VCByteArray alloc] initWithData:self.chunkData];
        return [arr readUInt32];
    }
    return 0;
}

+ (instancetype)makeAcknowledgement:(uint32_t)seq {
    VCRTMPMessage *message = [[VCRTMPMessage alloc] init];
    message.messageTypeID = VCRTMPMessageTypeAcknowledgement;
    VCRTMPChunk *chunk = [[VCRTMPChunk alloc] initWithType:VCRTMPChunkMessageHeaderType0 chunkStreamID:VCRTMPChunkStreamIDControl message:message];
    VCByteArray *arr = [[VCByteArray alloc] init];
    [arr writeUInt32:seq];
    chunk.chunkData = arr.data;
    return chunk;
}

- (uint32_t)acknowledgementValue {
    if (self.message.messageTypeID == VCRTMPMessageTypeAcknowledgement) {
        VCByteArray *arr = [[VCByteArray alloc] initWithData:self.chunkData];
        return [arr readUInt32];
    }
    return 0;
}

+ (instancetype)makeWindowAcknowledgementSize:(uint32_t)windowSize {
    VCRTMPMessage *message = [[VCRTMPMessage alloc] init];
    message.messageTypeID = VCRTMPMessageTypeWindowAcknowledgement;
    VCRTMPChunk *chunk = [[VCRTMPChunk alloc] initWithType:VCRTMPChunkMessageHeaderType0 chunkStreamID:VCRTMPChunkStreamIDControl message:message];
    VCByteArray *arr = [[VCByteArray alloc] init];
    [arr writeUInt32:windowSize];
    chunk.chunkData = arr.data;
    return chunk;
}

- (uint32_t)windowAcknowledgementSizeValue {
    if (self.message.messageTypeID == VCRTMPMessageTypeWindowAcknowledgement) {
        VCByteArray *arr = [[VCByteArray alloc] initWithData:self.chunkData];
        return [arr readUInt32];
    }
    return 0;
}

+ (instancetype)makeSetPeerBandwidth:(uint32_t)ackWindowSize
                           limitType:(VCRTMPChunkSetPeerBandwidthLimitType)limitType {
    VCRTMPMessage *message = [[VCRTMPMessage alloc] init];
    message.messageTypeID = VCRTMPMessageTypeSetPeerBandwidth;
    VCRTMPChunk *chunk = [[VCRTMPChunk alloc] initWithType:VCRTMPChunkMessageHeaderType0 chunkStreamID:VCRTMPChunkStreamIDControl message:message];
    VCByteArray *arr = [[VCByteArray alloc] init];
    [arr writeUInt32:ackWindowSize];
    [arr writeUInt8:limitType];
    chunk.chunkData = arr.data;
    return chunk;
}
- (uint32_t)setPeerBandwidthValue {
    if (self.message.messageTypeID == VCRTMPMessageTypeSetPeerBandwidth) {
        VCByteArray *arr = [[VCByteArray alloc] initWithData:self.chunkData];
        return [arr readUInt32];
    }
    return 0;
}
- (uint8_t)limitTypeValue {
    if (self.message.messageTypeID == VCRTMPMessageTypeSetPeerBandwidth) {
        VCByteArray *arr = [[VCByteArray alloc] initWithData:self.chunkData];
        arr.postion += 4;
        return [arr readUInt8];
    }
    return 0;
}

@end
