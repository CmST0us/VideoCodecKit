//
//  VCRTMPChunkChannel.m
//  VideoCodecKit
//
//  Created by CmST0us on 2020/2/6.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import "VCRTMPChunkChannel.h"
#import "VCTCPSocket.h"
#import "VCByteArray.h"
#import "VCRTMPChunk.h"
#import "VCRTMPMessage.h"

#define kVCRTMPChunkChannelDefaultChunkSize (128)

@interface VCRTMPChunkChannel () <VCTCPSocketDelegate>
@property (nonatomic, strong) VCTCPSocket *socket;

@property (nonatomic, strong) NSData *lastData;
@property (nonatomic, strong) VCRTMPChunk *lastSendChunk;
@property (nonatomic, strong) VCRTMPChunk *lastReadChunk;
@end

@implementation VCRTMPChunkChannel

- (instancetype)init {
    self = [super init];
    if (self) {
        _lastData = [NSData data];
        _localChunkSize = kVCRTMPChunkChannelDefaultChunkSize;
    }
    return self;
}

+ (instancetype)channelForSocket:(VCTCPSocket *)socket {
    VCRTMPChunkChannel *channel = [[VCRTMPChunkChannel alloc] init];
    channel.socket = socket;
    channel.socket.delegate = channel;
    return channel;
}

- (dispatch_block_t)makeByteArrayPositionRecoveryBlock:(VCByteArray *)arr {
    NSInteger position = arr.postion;
    return ^{
        arr.postion = position;
    };
}

- (void)handleRecvData:(NSData *)recvData {
    VCByteArray *array = [[VCByteArray alloc] initWithData:self.lastData];
    [array writeBytes:recvData];
    array.postion = 0;
    while ([array bytesAvailable]) {
        VCRTMPChunk *chunk = [[VCRTMPChunk alloc] init];
        dispatch_block_t recoveryBlock = [self makeByteArrayPositionRecoveryBlock:array];
        @try {
            /// Read Basic Chunk Header
            uint8_t firstByte = [array readUInt8];
            uint8_t format = (firstByte >> 6) & 0x03;
            uint32_t csid = firstByte & 0x3F;
            chunk.messageHeaderType = format;
            if (csid == 0) {
                uint8_t secondByte = [array readUInt8];
                
                csid = secondByte + 64;
                chunk.chunkStreamID = csid;
            } else if (csid == 0x3F) {
                uint8_t secondByte = [array readUInt8];
                uint8_t thirdByte = [array readUInt8];
                
                csid = (thirdByte * 256) + (secondByte + 64);
                chunk.chunkStreamID = csid;
            } else {
                chunk.chunkStreamID = csid;
            }
            
            /// Read Message Header
            if (chunk.messageHeaderType == VCRTMPChunkMessageHeaderType3) {
                if (self.lastReadChunk.message.messageLength > 0) {
                    chunk.chunkData = [array readBytes:self.lastReadChunk.message.messageLength];
                }
            } else {
                VCRTMPMessage *message = [[VCRTMPMessage alloc] init];
                chunk.message = message;
                do {
                    message.timestamp = [array readUInt24];
                    
                    if (chunk.messageHeaderType == VCRTMPChunkMessageHeaderType2) {
                        break;
                    }
                    
                    message.messageLength = [array readUInt24];
                    message.messageTypeID = [array readUInt8];
                    
                    if (chunk.messageHeaderType == VCRTMPChunkMessageHeaderType1) {
                        break;
                    }
                    message.messageStreamID = [array readUInt32Little];
                } while (0);
                
                NSInteger externTimestampSize = [chunk extendedTimestampSize];
                if (externTimestampSize > 0) {
                    message.timestamp = [array readUInt32];
                }
                
                if (message.messageLength > 0) {
                    chunk.chunkData = [array readBytes:message.messageLength];
                }
            }
        } @catch (NSException *exception) {
            recoveryBlock();
            NSData *restData = [array readBytes:[array bytesAvailable]];
            self.lastData = restData;
            break;
        }
        
        self.lastReadChunk = chunk;
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(channel:didReceiveFrame:)]) {
            [self.delegate channel:self didReceiveFrame:chunk];
        }
    }
}

- (void)writeFrame:(VCRTMPChunk *)chunk {
    NSMutableData *sendData = [[NSMutableData alloc] init];
    __block VCRTMPChunk *lastChunk = chunk;
    [[self splitChunk:chunk] enumerateObjectsUsingBlock:^(VCRTMPChunk * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [sendData appendData:[obj makeChunk]];
        lastChunk = obj;
    }];
    self.lastSendChunk = lastChunk;
    [self.socket writeData:sendData];
}

#pragma mark - Split Chunk
- (NSArray<VCRTMPChunk *> *)splitChunk:(VCRTMPChunk *)chunk {
    NSInteger chunkSize = self.localChunkSize;
    NSInteger chunkDataSize = chunk.message.messageLength;
    NSInteger splitChunkCount = chunkDataSize / chunkSize;
    NSInteger lastSplitChunkDataSize = chunkDataSize % chunkSize;
    
    if (splitChunkCount == 0) {
        [self modifyChunkMessageType:chunk
                   withLastSendChunk:self.lastSendChunk];
        return @[chunk];
    }
    
    NSMutableArray<VCRTMPChunk *> *chunks = [[NSMutableArray alloc] init];
    VCRTMPChunk *lastChunk = self.lastSendChunk;
    VCByteArray *array = [[VCByteArray alloc] initWithData:chunk.chunkData];
    for (NSInteger i = 0; i < splitChunkCount; ++i) {
        NSData *splitData = [array readBytes:chunkSize];
        VCRTMPChunk *splitChunk = [[VCRTMPChunk alloc] initWithType:lastChunk ? lastChunk.messageHeaderType : chunk.messageHeaderType
                                                      chunkStreamID:lastChunk ? lastChunk.chunkStreamID : chunk.chunkStreamID
                                                            message:lastChunk ? [lastChunk.message copy] : [chunk.message copy]];
        splitChunk.chunkData = splitData;
        [self modifyChunkMessageType:splitChunk
                   withLastSendChunk:lastChunk];
        [chunks addObject:splitChunk];
        lastChunk = splitChunk;
    }
    NSData *splitData = [array readBytes:lastSplitChunkDataSize];
    VCRTMPChunk *splitChunk = [[VCRTMPChunk alloc] initWithType:lastChunk.messageHeaderType
                                                  chunkStreamID:lastChunk.chunkStreamID
                                                        message:[lastChunk.message copy]];
    splitChunk.chunkData = splitData;
    [self modifyChunkMessageType:splitChunk
               withLastSendChunk:lastChunk];
    [chunks addObject:splitChunk];
    return chunks;
}

- (void)modifyChunkMessageType:(VCRTMPChunk *)aChunk withLastSendChunk:(VCRTMPChunk *)lastSendChunk {
    // TODO: Timestamp delta
    VCRTMPChunkMessageHeaderType newMessageType = aChunk.messageHeaderType;
    if (lastSendChunk &&
        lastSendChunk.message.messageStreamID == aChunk.message.messageStreamID) {
        newMessageType = VCRTMPChunkMessageHeaderType1;
        if (lastSendChunk.message.messageLength == aChunk.message.messageLength &&
            lastSendChunk.message.messageTypeID == aChunk.message.messageTypeID) {
            newMessageType = VCRTMPChunkMessageHeaderType2;
            if (lastSendChunk.message.timestamp == aChunk.message.timestamp) {
                newMessageType = VCRTMPChunkMessageHeaderType3;
            }
        }
    }
    aChunk.messageHeaderType = newMessageType;
}

#pragma mark - #pragma mark - TCP Delegate
- (void)tcpSocketEndcountered:(VCTCPSocket *)socket {
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(channelConnectionDidEnd)]) {
        [self.delegate channelConnectionDidEnd];
    }
}

- (void)tcpSocketErrorOccurred:(VCTCPSocket *)socket stream:(nonnull NSStream *)stream{
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(channel:connectionHasError:)]) {
        [self.delegate channel:self connectionHasError:stream.streamError];
    }
}

- (void)tcpSocketConnectTimeout:(VCTCPSocket *)socket {
    /// Pass
}

- (void)tcpSocketDidConnected:(nonnull VCTCPSocket *)socket {
    /// Pass
}

- (void)tcpSocketHasByteAvailable:(VCTCPSocket *)socket {
    NSData *recvData = [socket readData];
    if (recvData &&
        recvData.length > 0) {
        [self handleRecvData:recvData];
    } else {
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(channelConnectionDidEnd)]) {
            [self.delegate channelConnectionDidEnd];
        }
        [self.socket close];
    }
}

@end
