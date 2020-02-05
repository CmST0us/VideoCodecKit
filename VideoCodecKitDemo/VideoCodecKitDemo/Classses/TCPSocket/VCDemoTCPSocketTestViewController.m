//
//  VCDemoTCPSocketTestViewController.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2019/2/14.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <VideoCodecKit/VideoCodecKit.h>
#import "VCDemoTCPSocketTestViewController.h"
@interface VCDemoTCPSocketTestViewController () <VCTCPSocketDelegate>
@property (nonatomic, strong) VCTCPSocket *socket;
@property (nonatomic, strong) NSTimer *timer;
@end
@implementation VCDemoTCPSocketTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.socket = [[VCTCPSocket alloc] initWithHost:@"127.0.0.1" port:12002];
    self.socket.delegate = self;
    [self.socket connect];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        if (self.socket.connected) {
            [self.socket writeData:[@"Hello\n" dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }];
}

- (void)onBack:(UIButton *)button {
    [self.timer invalidate];
    self.timer = nil;
    [super onBack:button];
}
- (void)tcpSocketEndcountered:(VCTCPSocket *)socket {
    NSLog(@"EOF");
    [socket close];
}

- (void)tcpSocketHasByteAvailable:(VCTCPSocket *)socket {
    NSData *data = [socket readData];
    if (data == nil) {
        return;
    }
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@", str);
}

- (void)tcpSocketDidConnected:(VCTCPSocket *)socket {
    NSLog(@"CONNECT");
}

- (void)tcpSocketErrorOccurred:(VCTCPSocket *)socket {
    NSLog(@"ERROR");
    [socket close];
}

- (void)tcpSocketConnectTimeout:(VCTCPSocket *)socket {
    NSLog(@"TIMEOUT");
    [socket close];
}

@end
