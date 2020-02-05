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
@end

@implementation VCDemoRTMPHandshakeTestViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.socket = [[VCTCPSocket alloc] initWithHost:@"127.0.0.1" port:1935];
    self.handshake = [VCRTMPHandshake handshakeForSocket:self.socket];
    [self.handshake startHandshakeWithBlock:^(VCRTMPHandshake * _Nonnull handshake, BOOL isSuccess, NSError * _Nullable error) {
        if (isSuccess) {
            NSLog(@"握手成功");
        } else {
            NSLog(@"握手失败: %@", error);
        }
    }];
}

@end
