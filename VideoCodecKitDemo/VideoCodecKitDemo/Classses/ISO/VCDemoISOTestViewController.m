//
//  VCDemoISOTestViewController.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2019/1/27.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "VCDemoISOTestViewController.h"
#import <VideoCodecKit/VideoCodecKit.h>

@interface VCDemoISOTestViewController ()

@end

@implementation VCDemoISOTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    uint8_t d[] = {
        0x00, 0x00, 0x00, 0x01, 0x00, 0x23, 0x32, 0x11, 0x00, 0x00, 0x03, 0x01, 0x00, 0x00, 0x01, 0x65, 0x00, 0x00, 0x00, 0x01, 0x67, 0x00, 0x03
    };
    NSData *data = [[NSData alloc] initWithBytes:d length:sizeof(d)];
    VCAnnexBFormatStream *s = [[VCAnnexBFormatStream alloc] initWithData:data];
    VCAVCFormatStream *avc = [s toAVCFormatStream];
}


@end
