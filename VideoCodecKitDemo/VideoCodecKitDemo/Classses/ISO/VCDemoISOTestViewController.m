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
//    uint8_t d[] = {
//        0x00, 0x00, 0x00, 0x01, 0x00, 0x23, 0x00, 0x00, 0x01, 0x65, 0x00, 0x00, 0x00, 0x01, 0x67, 0x00, 0x03
//    };
//    NSData *data = [[NSData alloc] initWithBytes:d length:sizeof(d)];
//    VCAnnexBFormatStream *s = [[VCAnnexBFormatStream alloc] initWithData:data];
//    VCAVCFormatStream *avc = [s toAVCFormatStream];
//
//    VCAnnexBFormatParser *parser = [[VCAnnexBFormatParser alloc] init];
//    [parser appendData:data];
//
//    VCAnnexBFormatStream *nextStream = nil;
//    while ((nextStream = [parser next]) != nil) {
//        VCAVCFormatStream *avcS = [nextStream toAVCFormatStream];
//    }
    
    // File Test
//    NSInputStream *readStream = [[NSInputStream alloc] initWithFileAtPath:@"/Users/cmst0us/Desktop/swift.h264"];
//    [readStream open];
//
//    while ([readStream hasBytesAvailable]) {
//        uint8_t readBuffer[4096] = {0};
//        NSInteger readLen = [readStream read:readBuffer maxLength:4096];
//
//        [parser appendData:[NSData dataWithBytes:readBuffer length:readLen]];
//        VCAnnexBFormatStream *next = nil;
//        do {
//            next = [parser next];
//            VCAVCFormatStream *avc = [next toAVCFormatStream];
//
//        } while (next != nil);
//
//    }
    VCFLVFile *flv = [[VCFLVFile alloc] initWithURL:[NSURL fileURLWithPath:@"/Users/cmst0us/Desktop/test.flv"]];
    VCFLVTag *tag = nil;
    do {
        tag = [flv nextTag];
        if (tag) {
            NSLog(@"%@", tag);
        }
    } while (tag != nil);
}


@end
