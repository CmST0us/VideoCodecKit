//
//  VCRTMPHandshake.m
//  VideoCodecKit
//
//  Created by CmST0us on 2019/2/12.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "VCRTMPHandshake.h"
#import "VCRTMPNetConnection.h"
#import "VCByteArray.h"
#import "VCSafeBuffer.h"
#import "VCRTMPChunk.h"
#import "VCRTMPMessage.h"

#define kVCRTMPHandshakeProtocolVersion (3)

#define kVCRTMPHandshakeC0AndS0Size (1)
#define kVCRTMPHandshakeC1AndS1Size (1536)
#define kVCRTMPHandshakeC2AnsS2Size (1536)

#define kVCRTMPHandshakeRandomDataSize (1528)

NSErrorDomain const VCRTMPHandshakeErrorDomain = @"VCRTMPHandshakeErrorDomain";

@interface VCRTMPHandshake ()<VCTCPSocketDelegate>
@property (nonatomic, assign) VCRTMPHandshakeState state;
@property (nonatomic, strong) VCSafeBuffer *buffer;

@property (nonatomic, weak) VCTCPSocket *socket;
@property (nonatomic, copy) VCRTMPHandshakeBlock handler;

@property (nonatomic, assign) int32_t clientTimestamp;
@property (nonatomic, assign) int32_t serverTimestamp;

@property (nonatomic, strong) NSData *clientRandomData;
@property (nonatomic, strong) NSData *serverRandomData;
@end

@implementation VCRTMPHandshake

- (instancetype)init {
    self = [super init];
    if (self) {
        _state = VCRTMPHandshakeStateUninitialized;
        _version = kVCRTMPHandshakeProtocolVersion;
        _handler = nil;
        _buffer = [[VCSafeBuffer alloc] init];
    }
    return self;
}

+ (instancetype)handshakeForSocket:(VCTCPSocket *)socket {
    VCRTMPHandshake *handshake = [[VCRTMPHandshake alloc] init];
    handshake.socket = socket;
    socket.delegate = handshake;
    return handshake;
}

#pragma mark - Make Handshake Packet
- (NSData *)makeC0Packet {
    VCByteArray *array = [[VCByteArray alloc] init];
    [array writeUInt8:self.version];
    return array.data;
}

- (NSData *)makeC1Packet {
    VCByteArray *array = [[VCByteArray alloc] init];
    self.clientTimestamp = [[NSDate date] timeIntervalSince1970];
    [array writing:^(VCByteArrayWriter * _Nonnull writer) {
        writer.writeInt32(self.clientTimestamp).writeUInt32(0);
        NSMutableData *randomData = [[NSMutableData alloc] init];
        for (int i = 0; i < kVCRTMPHandshakeRandomDataSize; ++i) {
            uint8_t randomByte = arc4random_uniform(0xFF);
            [randomData appendBytes:&randomByte length:1];
        }
        self.clientRandomData = randomData;
        writer.writeBytes(randomData);
    }];
    return array.data;
}

- (NSData *)makeC0C1Packet {
    NSMutableData *data = [[NSMutableData alloc] initWithData:[self makeC0Packet]];
    [data appendData:[self makeC1Packet]];
    return data;
}

- (NSData *)makeC2PacketWithS0S1Packet:(NSData *)s0s1 {
    return [self makeC2PacketWithS1Packet:[s0s1 subdataWithRange:NSMakeRange(1, s0s1.length - 1)]];
}

- (NSData *)makeC2PacketWithS1Packet:(NSData *)s1 {
    VCByteArray *array = [[VCByteArray alloc] init];
    [array writing:^(VCByteArrayWriter * _Nonnull writer) {
        writer.writeBytes([s1 subdataWithRange:NSMakeRange(0, 4)]).writeInt32(self.clientTimestamp);
        writer.writeBytes([s1 subdataWithRange:NSMakeRange(8, kVCRTMPHandshakeRandomDataSize)]);
    }];
    return array.data;
}

#pragma mark - Verify Handshake Packet
- (BOOL)verifyS0S1:(NSData *)s0s1 {
    if (s0s1.length != kVCRTMPHandshakeC0AndS0Size + kVCRTMPHandshakeC1AndS1Size) {
        return NO;
    }
    VCByteArray *byteArray = [[VCByteArray alloc] initWithData:s0s1];
    
    /// Reference: 5.2.2 C0 and S0 Format
    uint8_t version = [byteArray readUInt8];
    if (version != self.version) {
        return NO;
    }
    
    self.serverTimestamp = [byteArray readUInt32];
    /// Reference: 5.2.3 C1 and S1 Format
    uint32_t zeroField = [byteArray readUInt32];
    if (zeroField != 0) {
        return NO;
    }
    self.serverRandomData = [byteArray readBytes:kVCRTMPHandshakeRandomDataSize];
    return YES;
}

- (BOOL)verifyS2:(NSData *)s2 {
    if (s2.length != kVCRTMPHandshakeC2AnsS2Size) {
        return NO;
    }
    VCByteArray *byteArray = [[VCByteArray alloc] initWithData:s2];
    uint32_t time = [byteArray readUInt32];
    if (time != self.clientTimestamp) {
        return NO;
    }
    uint32_t time2 = [byteArray readUInt32];
    if (time2 != self.serverTimestamp) {
        /// 有些服务器中，会把C2S2的时间戳校验放到C1S1,即服务器收到C2后才发送S0S1
        /// 此时C1.time == S1.time
        if (self.clientTimestamp != self.serverTimestamp) {
            return NO;
        }
        
    }
    NSData *randomData = [byteArray readBytes:kVCRTMPHandshakeRandomDataSize];
    if (![randomData isEqualToData:self.clientRandomData]) {
        return NO;
    }
    return YES;
}

#pragma mark - Handshake Session
- (void)startHandshakeWithBlock:(VCRTMPHandshakeBlock)block {
    _handler = block;
    /// 开始连接远端
    [self.socket connect];
}

- (void)handleSendC0C1 {
    if (!kVCAllowState(@[@(VCRTMPHandshakeStateUninitialized)], @(self.state))) {
        [self handleHandshakeErrorWithCode:VCRTMPHandshakeErrorCodeUnknow];
        return;
    }
    [self.socket writeData:[self makeC0C1Packet]];
    self.state = VCRTMPHandshakeStateVersionSent;
}

- (void)handleContinueSendAckWithS0S1:(NSData *)s0s1 {
    if (!kVCAllowState(@[@(VCRTMPHandshakeStateVersionSent)], @(self.state))) {
        [self handleHandshakeErrorWithCode:VCRTMPHandshakeErrorCodeUnknow];
        return;
    }
    [self.socket writeData:[self makeC2PacketWithS0S1Packet:s0s1]];
    self.state = VCRTMPHandshakeStateAckSent;
}

- (void)handleHandshakeDone {
    if (!kVCAllowState(@[@(VCRTMPHandshakeStateAckSent)], @(self.state))) {
        [self handleHandshakeErrorWithCode:VCRTMPHandshakeErrorCodeUnknow];
        return;
    }
    
    self.state = VCRTMPHandshakeStateHandshakeDone;
    self.handler(self, YES, nil);
}

- (void)handleHandshakeErrorWithCode:(VCRTMPHandshakeErrorCode)code {
    self.state = VCRTMPHandshakeStateError;
    [self.socket close];
    if (self.handler) {
        self.handler(self, NO, [NSError errorWithDomain:VCRTMPHandshakeErrorDomain code:code userInfo:nil]);
    }
}

- (void)handleHandshakePacket {
    switch (self.state) {
        case VCRTMPHandshakeStateVersionSent: {
            /// 收到S0 S1
            NSInteger len = kVCRTMPHandshakeC0AndS0Size + kVCRTMPHandshakeC1AndS1Size;
            if (self.buffer.count >= len) {
                NSData *s0s1 = [self.buffer pull:&len];
                if ([self verifyS0S1:s0s1]) {
                    [self handleContinueSendAckWithS0S1:s0s1];
                } else {
                    [self handleHandshakeErrorWithCode:VCRTMPHandshakeErrorCodeVerifyS0S1];
                }
                [self handleHandshakePacket];
            } else {
                return;
            }
        }
            break;
        case VCRTMPHandshakeStateAckSent: {
            /// 收到S2
            NSInteger len = kVCRTMPHandshakeC2AnsS2Size;
            if (self.buffer.count >= len) {
                NSData *s2 = [self.buffer pull:&len];
                if ([self verifyS2:s2]) {
                    [self handleHandshakeDone];
                } else {
                    [self handleHandshakeErrorWithCode:VCRTMPHandshakeErrorCodeVerifyS2];
                }
                [self handleHandshakePacket];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - Finish Handshake
- (void)setChunkSize:(uint32_t)size withCompletion:(dispatch_block_t)block {
    VCByteArray *arr = [[VCByteArray alloc] init];
    size = MIN(size, 0x7FFFFFFF);
    [arr writeUInt32:size];
    VCRTMPMessage *message = [[VCRTMPMessage alloc] init];
    message.messageTypeID = VCRTMPMessageTypeSetChunkSize;
    VCRTMPChunk *chunk = [[VCRTMPChunk alloc] initWithType:VCRTMPChunkMessageHeaderType0 chunkStreamID:VCRTMPChunkStreamIDControl message:message];
    chunk.chunkData = arr.data;
    [self.socket writeData:[chunk makeChunk]];
}

- (VCRTMPNetConnection *)makeNetConnection {
    if (!kVCAllowState(@[@(VCRTMPHandshakeStateHandshakeDone)], @(self.state))) {
        return nil;
    }
    return [VCRTMPNetConnection netConnectionForSocket:self.socket];
}

#pragma mark - TCP Socket Delegate
- (void)tcpSocketEndcountered:(VCTCPSocket *)socket {
    [self handleHandshakeErrorWithCode:VCRTMPHandshakeErrorCodeConnectReset];
}

- (void)tcpSocketErrorOccurred:(VCTCPSocket *)socket {
    [self handleHandshakeErrorWithCode:VCRTMPHandshakeErrorCodeConnectError];
}

- (void)tcpSocketConnectTimeout:(VCTCPSocket *)socket {
    [self handleHandshakeErrorWithCode:VCRTMPHandshakeErrorCodeConnectTimeout];
}

- (void)tcpSocketHasByteAvailable:(VCTCPSocket *)socket {
    NSArray * const allow = @[
        @(VCRTMPHandshakeStateUninitialized),
        @(VCRTMPHandshakeStateVersionSent),
        @(VCRTMPHandshakeStateAckSent)
    ];
    if (!kVCAllowState(allow, @(self.state))) {
        return;
    }
    
    while ([self.socket byteAvaliable]) {
        [self.buffer push:[[VCSafeBufferNode alloc] initWithData:[self.socket readData]]];
    }
    [self handleHandshakePacket];
}

- (void)tcpSocketDidConnected:(nonnull VCTCPSocket *)socket {
    [self handleSendC0C1];
}

@end
