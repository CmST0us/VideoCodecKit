//
//  VCRTMPSocket.m
//  VideoCodecKit
//
//  Created by CmST0us on 2019/2/12.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "VCRTMPSocket.h"
#import "VCTCPSocket.h"
#import "VCRTMPHandshake.h"

@interface VCRTMPSocket ()<VCTCPSocketDelegate>
@property (nonatomic, strong) VCTCPSocket *socket;
@property (nonatomic, strong) VCRTMPHandshake *handshake;

@property (nonatomic, assign) BOOL connected;
@end

@implementation VCRTMPSocket

- (instancetype)init {
    self = [super init];
    if (self) {
        _connected = NO;
    }
    return self;
}

- (VCTCPSocket *)socket {
    if (_socket != nil) {
        return _socket;
    }
    _socket = [[VCTCPSocket alloc] init];
    _socket.delegate = self;
    return _socket;
}

- (void)connectHost:(NSString *)host withPort:(NSInteger)port {
    [self.socket connectWithHost:host port:port];
}

- (void)writeData:(NSData *)data {
    [self.socket writeData:data];
}

- (NSData *)readData {
    return [self.socket readData];
}

- (void)close {
    [self.socket close];
}

- (void)startHandshake {
    __weak typeof(self) weakSelf = self;
    self.handshake = [VCRTMPHandshake handshakeForSocket:self];
    [self.handshake startHandshakeWithBlock:^(VCRTMPHandshake * _Nonnull handshake, BOOL isSuccess, NSError * _Nonnull error) {
        if (isSuccess && error == nil) {
            weakSelf.connected = YES;
        } else {
            weakSelf.connected = NO;
        }
    }];
}

#pragma mark - TCP Delegate
- (void)tcpSocketDidConnected:(VCTCPSocket *)socket {
    if (socket != self.socket) {
        return;
    }
    if (!_connected) {
        [self startHandshake];
    }
}

- (void)tcpSocketEndcountered:(VCTCPSocket *)socket {
    
}

- (void)tcpSocketErrorOccurred:(VCTCPSocket *)socket {
    
}

- (void)tcpSocketConnectTimeout:(VCTCPSocket *)socket {
    
}

- (void)tcpSocketHasByteAvailable:(VCTCPSocket *)socket {
    
}

@end
