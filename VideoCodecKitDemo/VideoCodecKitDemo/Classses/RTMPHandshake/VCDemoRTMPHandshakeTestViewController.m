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
@property (nonatomic, strong) VCRTMPSocket *socket;
@end

@implementation VCDemoRTMPHandshakeTestViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.socket = [[VCRTMPSocket alloc] init];
    [self.socket connectHost:@"js.live-send.acg.tv" withPort:1935];
}
@end
