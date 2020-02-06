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

#define kVCRTMPChunkHeaderMaxSize (18)

@interface VCRTMPChunk ()
@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, assign) uint8_t *inputStreamReadBuffer;
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

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithInputStream:(NSInputStream *)inputStream {
    self = [super init];
    if (self) {
        _inputStream = inputStream;
        _inputStreamReadBuffer = malloc(kVCRTMPChunkHeaderMaxSize);
    }
    return self;
}

- (void)dealloc {
    if (_inputStreamReadBuffer) {
        free(_inputStreamReadBuffer);
        _inputStreamReadBuffer = NULL;
    }
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

#pragma mark - Decode Chunk
- (BOOL)readChunk {
    if (self.inputStream == nil) {
        return NO;
    }
    
    /// Read Format
    NSInteger readLen = [self.inputStream read:self.inputStreamReadBuffer maxLength:1];
    if (readLen != 1) {
        return NO;
    }
    uint8_t format = (self.inputStreamReadBuffer[0] >> 6) & 0x03;
    uint32_t csid = self.inputStreamReadBuffer[0] & 0x3F;
    self.messageHeaderType = format;
    if (csid == 0) {
        readLen = [self.inputStream read:self.inputStreamReadBuffer maxLength:1];
        if (readLen != 1) {
            return NO;
        }
        csid = self.inputStreamReadBuffer[0] + 64;
        self.chunkStreamID = csid;
    } else if (csid == 0x3F) {
        readLen = [self.inputStream read:self.inputStreamReadBuffer maxLength:2];
        if (readLen != 2) {
            return NO;
        }
        uint8_t secondByte = self.inputStreamReadBuffer[0];
        uint8_t thirdByte = self.inputStreamReadBuffer[1];
        csid = (thirdByte * 256) + (secondByte + 64);
        self.chunkStreamID = csid;
    } else {
        self.chunkStreamID = csid;
    }
    
    if (self.messageHeaderType == VCRTMPChunkMessageHeaderType3) {
        if (self.chunkDataDefaultSize > 0) {
            void *buffer = malloc(self.chunkDataDefaultSize);
            readLen = [self.inputStream read:buffer maxLength:self.chunkDataDefaultSize];
            if (readLen > 0) {
                NSData *data = [[NSData alloc] initWithBytesNoCopy:buffer length:readLen];
                self.chunkData = data;
            }
        }
    } else {
        VCRTMPMessage *message = [[VCRTMPMessage alloc] init];
        self.message = message;
        do {
            NSInteger messageHeaderSize = [self messageHeaderSize];
            readLen = [self.inputStream read:self.inputStreamReadBuffer maxLength:messageHeaderSize];
            if (readLen != messageHeaderSize) {
                return NO;
            }
            NSData *data = [[NSData alloc] initWithBytes:self.inputStreamReadBuffer length:readLen];
            VCByteArray *arr = [[VCByteArray alloc] initWithData:data];
            message.timestamp = [arr readUInt24];
            
            if (self.messageHeaderType == VCRTMPChunkMessageHeaderType2) {
                break;
            }
            
            message.messageLength = [arr readUInt24];
            message.messageTypeID = [arr readUInt8];
            
            if (self.messageHeaderType == VCRTMPChunkMessageHeaderType1) {
                break;
            }
            message.messageStreamID = CFSwapInt32LittleToHost([arr readUInt32]);
        } while (0);
        
        NSInteger externTimestampSize = [self extendedTimestampSize];
        if (externTimestampSize > 0) {
            readLen = [self.inputStream read:self.inputStreamReadBuffer maxLength:4];
            if (readLen != 4) {
                return NO;
            }
            uint32_t *p = (uint32_t *)self.inputStreamReadBuffer;
            self.message.timestamp = CFSwapInt32BigToHost(*p);
        }
        
        if (message.messageLength > 0) {
            void *buffer = malloc(message.messageLength);
            readLen = [self.inputStream read:buffer maxLength:message.messageLength];
            if (readLen != message.messageLength) {
                return NO;
            }
            NSData *data = [[NSData alloc] initWithBytesNoCopy:buffer length:readLen];
            self.chunkData = data;
        }
    }
    return YES;
}

@end
