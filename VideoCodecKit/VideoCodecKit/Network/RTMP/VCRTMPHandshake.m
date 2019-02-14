//
//  VCRTMPHandshake.m
//  VideoCodecKit
//
//  Created by CmST0us on 2019/2/12.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "VCRTMPHandshake.h"
#import "VCRTMPSocket.h"
#import "VCByteArray.h"
#import "VCSafeBuffer.h"

#define kVCRTMPHandshakeProtocolVersion (3)

@interface VCRTMPHandshake ()<VCTCPSocketDelegate>
@property (nonatomic, strong) VCSafeBuffer *buffer;

@property (nonatomic, weak) VCRTMPSocket *rtmpSocket;
@property (nonatomic, copy) VCRTMPHandshakeBlock handler;
@property (nonatomic, weak) id socketDelegate;
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

+ (instancetype)handshakeForSocket:(VCRTMPSocket *)socket {
    VCRTMPHandshake *handshake = [[VCRTMPHandshake alloc] init];
    handshake.socketDelegate = socket.socket.delegate;
    socket.socket.delegate = handshake;
    handshake.rtmpSocket = socket;
    return handshake;
}

#pragma mark - Handshake Packet
- (NSData *)makeC0Packet {
    VCByteArray *array = [[VCByteArray alloc] init];
    [array writeUInt8:self.version];
    return array.data;
}

- (NSData *)makeC1Packet {
    VCByteArray *array = [[VCByteArray alloc] init];
    [array writing:^(VCByteArrayWriter * _Nonnull writer) {
        writer.writeInt32(self.timestamp).writeUInt32(0);
        for (int i = 0; i < 1528; ++i) {
            writer.writeUInt8((uint8_t)arc4random_uniform(0xFF));
        }
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
        writer.writeBytes([s1 subdataWithRange:NSMakeRange(0, 4)]).writeInt32([[NSDate date] timeIntervalSince1970] - self.timestamp);
        writer.writeBytes([s1 subdataWithRange:NSMakeRange(8, 1528)]);
    }];
    return array.data;
}

#pragma mark - Handshake Packet
- (void)startHandshakeWithBlock:(VCRTMPHandshakeBlock)block {
    _handler = block;
    [self sendC0C1];
}

- (void)sendC0C1 {
    self.state = VCRTMPHandshakeStateVersionSending;
    [self.rtmpSocket writeData:[self makeC0C1Packet]];
    self.state = VCRTMPHandshakeStateVersionSent;
}

- (void)continueSendAck {
    // recv S0 S1
    NSInteger len = 1537;
    NSData *s0s1 = [self.buffer pull:&len];
    self.state = VCRTMPHandshakeStateAckSending;
    [self.rtmpSocket writeData:[self makeC2PacketWithS0S1Packet:s0s1]];
    self.state = VCRTMPHandshakeStateAckSent;
}

- (void)makeHandshakeDone {
    // recv S2
    NSInteger len = 1536;
    NSData *s2 = [self.buffer pull:&len];
    self.state = VCRTMPHandshakeStateHandshakeDone;
    self.rtmpSocket.socket.delegate = self.socketDelegate;
    self.handler(self, YES, nil);
}

- (void)makeHandshakeError {
    self.rtmpSocket.socket.delegate = self.socketDelegate;
    self.handler(self, NO, [NSError errorWithDomain:NSStreamSOCKSErrorDomain code:-1 userInfo:nil]);
}

#pragma mark - TCP Socket Delegate
- (void)tcpSocketEndcountered:(VCTCPSocket *)socket {
    [self makeHandshakeError];
}

- (void)tcpSocketErrorOccurred:(VCTCPSocket *)socket {
    [self makeHandshakeError];
}

- (void)tcpSocketConnectTimeout:(VCTCPSocket *)socket {
    [self makeHandshakeError];
}

- (void)tcpSocketHasByteAvailable:(VCTCPSocket *)socket {
    [self.buffer push:[[VCSafeBufferNode alloc] initWithData:[self.rtmpSocket readData]]];
    switch (self.state) {
        case VCRTMPHandshakeStateVersionSent:
            if (self.buffer.count >= 1537) {
                [self continueSendAck];
            }
        case VCRTMPHandshakeStateAckSent:
            if (self.buffer.count >= 1536) {
                [self makeHandshakeDone];
            }
        default:
            break;
    }
}

- (void)tcpSocketDidConnected:(nonnull VCTCPSocket *)socket {
    
}

@end
