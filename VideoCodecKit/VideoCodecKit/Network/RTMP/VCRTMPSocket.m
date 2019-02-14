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

#define kVCRTMPSocketDefaultTimeout (15)
@interface VCRTMPSocket ()<VCTCPSocketDelegate>
@property (nonatomic, strong) VCTCPSocket *socket;
@property (nonatomic, strong) VCRTMPHandshake *handshake;
@property (nonatomic, strong) NSTimer *timeoutTimer;
@property (nonatomic, assign) BOOL connected;
@end

@implementation VCRTMPSocket

- (instancetype)init {
    self = [super init];
    if (self) {
        _connected = NO;
        _timeout = kVCRTMPSocketDefaultTimeout;
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
    self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:self.timeout repeats:NO block:^(NSTimer * _Nonnull timer) {
        if (!self.connected &&
            self.delegate &&
            [self.delegate respondsToSelector:@selector(rtmpSocketConnectedTimeout:)]) {
            [self.delegate rtmpSocketConnectedTimeout:self];
        }
    }];
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

- (void)finishConnect {
    [self.timeoutTimer invalidate];
    self.timeoutTimer = nil;
}

- (void)startHandshake {
    __weak typeof(self) weakSelf = self;
    self.handshake = [VCRTMPHandshake handshakeForSocket:self];
    [self.handshake startHandshakeWithBlock:^(VCRTMPHandshake * _Nonnull handshake, BOOL isSuccess, NSError * _Nonnull error) {
        if (isSuccess && error == nil) {
            weakSelf.connected = YES;
            [weakSelf finishConnect];
            if (weakSelf.delegate &&
                [weakSelf.delegate respondsToSelector:@selector(rtmpSocketDidConnected:)]) {
                [weakSelf.delegate rtmpSocketDidConnected:weakSelf];
            }
        } else {
            weakSelf.connected = NO;
            [weakSelf finishConnect];
            if (weakSelf.delegate &&
                [weakSelf.delegate respondsToSelector:@selector(rtmpSocketErrorOccurred:)]) {
                [weakSelf.delegate rtmpSocketErrorOccurred:weakSelf];
            }
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
