//
//  VCDemoRTMPHandshakeTestViewController.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2019/2/15.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <VideoCodecKit/VideoCodecKit.h>
#import "VCDemoRTMPHandshakeTestViewController.h"

@interface VCDemoRTMPHandshakeTestViewController ()
@property (nonatomic, strong) VCTCPSocket *socket;
@property (nonatomic, strong) VCRTMPHandshake *handshake;
@property (nonatomic, strong) VCRTMPNetConnection *netConnection;
@end

@implementation VCDemoRTMPHandshakeTestViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.socket = [[VCTCPSocket alloc] initWithHost:@"127.0.0.1" port:1935];
    self.handshake = [VCRTMPHandshake handshakeForSocket:self.socket];
    __weak typeof(self) weakSelf = self;
    [self.handshake startHandshakeWithBlock:^(VCRTMPHandshake * _Nonnull handshake, BOOL isSuccess, NSError * _Nullable error) {
        if (isSuccess) {
            NSLog(@"握手成功");
            [handshake setChunkSize:4096 withCompletion:nil];
            [weakSelf handleHandshakeSuccess];
        } else {
            NSLog(@"握手失败: %@", error);
        }
    }];
}

- (void)handleHandshakeSuccess {
    self.netConnection = [self.handshake makeNetConnection];
    NSDictionary *parm = @{
        @"app": @"VideoCodecKit::RTMP".asString,
        @"tcUrl": @"rtmp://127.0.0.1/stream".asString,
        @"flashVer": @"FMLE/3.0 (compatible; FMSc/1.0)".asString,
        @"swfUrl": NSNull.asNull,
        @"fpad": @(NO).asBool,
        @"audioCodecs": @(0x0400).asNumber,
        @"videoCodecs": @(0x0080).asNumber,
        @"objectEncodeing": @(0).asNumber,
    };
    [self.netConnection connecWithParam:parm];
}
@end
