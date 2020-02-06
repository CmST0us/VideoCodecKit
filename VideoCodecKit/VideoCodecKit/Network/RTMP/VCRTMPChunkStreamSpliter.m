//
//  VCRTMPChunkStreamSpliter.m
//  VideoCodecKit
//
//  Created by CmST0us on 2020/2/6.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import "VCRTMPChunkStreamSpliter.h"
#import "VCTCPSocket.h"
#import "VCByteArray.h"
#import "VCRTMPChunk.h"
#import "VCRTMPMessage.h"

@interface VCRTMPChunkStreamSpliter () <VCTCPSocketDelegate>
@property (nonatomic, strong) VCTCPSocket *socket;

@property (nonatomic, strong) NSData *lastData;
@end

@implementation VCRTMPChunkStreamSpliter

- (instancetype)init {
    self = [super init];
    if (self) {
        _lastData = [NSData data];
    }
    return self;
}

+ (instancetype)spliterForSocket:(VCTCPSocket *)socket {
    VCRTMPChunkStreamSpliter *spliter = [[VCRTMPChunkStreamSpliter alloc] init];
    spliter.socket = socket;
    spliter.socket.delegate = spliter;
    return spliter;
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
                if (self.chunkDataDefaultSize > 0) {
                    chunk.chunkData = [array readBytes:self.chunkDataDefaultSize];
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
                    message.messageStreamID = CFSwapInt32LittleToHost([array readUInt32]);
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
        
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(spliter:didReceiveFrame:)]) {
            [self.delegate spliter:self didReceiveFrame:chunk];
        }
    }
}

- (void)writeFrame:(VCRTMPChunk *)chunk {
    [self.socket writeData:[chunk makeChunk]];
}

#pragma mark - #pragma mark - TCP Delegate
- (void)tcpSocketEndcountered:(VCTCPSocket *)socket {
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(spliterConnectionDidEnd)]) {
        [self.delegate spliterConnectionDidEnd];
    }
}

- (void)tcpSocketErrorOccurred:(VCTCPSocket *)socket stream:(nonnull NSStream *)stream{
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(spliter:connectionHasError:)]) {
        [self.delegate spliter:self connectionHasError:stream.streamError];
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
            [self.delegate respondsToSelector:@selector(spliterConnectionDidEnd)]) {
            [self.delegate spliterConnectionDidEnd];
        }
        [self.socket close];
    }
}

@end
