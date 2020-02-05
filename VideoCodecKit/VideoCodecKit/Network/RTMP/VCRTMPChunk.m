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

@implementation VCRTMPChunk

- (instancetype)initWithType:(VCRTMPChunkMessageHeaderType)type
               chunkStreamID:(VCRTMPChunkStreamID)chunkStreamID
                     message:(VCRTMPMessage *)message {
    self = [super init];
    if (self) {
        self.messageHeaderType = type;
        self.chunkStreamID = chunkStreamID;
        self.message = message;
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        
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
    if (self.message.timestamp >= 0xFFFFFF) {
        return 4;
    }
    return 0;
}

- (void)setChunkData:(NSData *)chunkData {
    _chunkData = chunkData;
    self.message.messageLength = (uint32_t)chunkData.length;
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
        header[0] = (self.messageHeaderType << 6) | 0x01;
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

@end
