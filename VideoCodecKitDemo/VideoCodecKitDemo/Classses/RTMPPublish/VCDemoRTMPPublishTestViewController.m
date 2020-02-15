//
//  VCDemoRTMPPublishTestViewController.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2019/2/15.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <VideoCodecKit/VideoCodecKit.h>
#import "VCDemoRTMPPublishTestViewController.h"

@interface VCDemoRTMPPublishTestViewController () <VCRTMPPublisherDelegate>
@property (nonatomic, strong) VCRTMPPublisher *publisher;
@property (nonatomic, strong) VCFLVFile *flvFile;
@property (nonatomic, strong) dispatch_queue_t publishQueue;
@end

@implementation VCDemoRTMPPublishTestViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.publishQueue = dispatch_queue_create("PublishQueue", DISPATCH_QUEUE_SERIAL);
    
    self.publisher = [[VCRTMPPublisher alloc] initWithURL:[NSURL URLWithString:@"rtmp://127.0.0.1/stream"] publishKey:@"12345"];
    self.publisher.delegate = self;
    self.publisher.connectionParameter = @{
        @"flashVer": @"FMLE/3.0 (compatible; FMSc/1.0)".asString,
        @"swfUrl": NSNull.asNull,
        @"fpad": @(NO).asBool,
        @"audioCodecs": @(0x0400).asNumber,
        @"videoCodecs": @(0x0080).asNumber,
        @"objectEncodeing": @(0).asNumber,
    };
    self.publisher.streamMetaData = @{
        @"duration": @(0).asNumber,
        @"fileSize": @(0).asNumber,
        @"width": @(1280).asNumber,
        @"height": @(720).asNumber,
        @"videocodecid": @"avc1".asString,
        @"videodatarate": @(2500).asNumber,
        @"framerate": @(30).asNumber,
        @"audiocodecid": @"mp4a".asString,
        @"audiodatarate": @(160).asNumber,
        @"audiosamplerate": @"44100".asString,
        @"audiosamplesize": @(16).asNumber,
        @"audiochannels": @(2).asNumber,
        @"stereo": @(YES).asBool,
        @"2.1": @(NO).asBool,
        @"3.1": @(NO).asBool,
        @"4.0": @(NO).asBool,
        @"4.1": @(NO).asBool,
        @"5.1": @(NO).asBool,
        @"7.1": @(NO).asBool,
        @"encoder": @"iOSVT::VideoCodecKit".asString,
    };
    [self.publisher start];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.publisher stop];
}

- (void)handleStartPublish {
    dispatch_async(self.publishQueue, ^{
        self.flvFile = [[VCFLVFile alloc] initWithURL:[[NSBundle mainBundle] URLForResource:@"test" withExtension:@"flv"]];
        VCFLVTag *tag = [self.flvFile nextTag];
        do {
            @autoreleasepool {
                [self.publisher writeTag:tag];
                tag = [self.flvFile nextTag];
                if (self.publisher.state != VCRTMPPublisherStateReadyToPublish) {
                    break;
                }
            }
            [NSThread sleepForTimeInterval:0.008];
        } while (tag != nil);
        if (self.publisher.state == VCRTMPPublisherStateReadyToPublish) {
            [self handleStartPublish];
        }
    });
}

#pragma mark - Delegate
- (void)publisher:(VCRTMPPublisher *)publisher didChangeState:(VCRTMPPublisherState)state error:(NSError *)error {
    if (state == VCRTMPPublisherStateReadyToPublish) {
        NSLog(@"Publisher Ready");
        [self handleStartPublish];
    } else if (state == VCRTMPPublisherStateError) {
        NSLog(@"Publisher Error %@", error);
    } else if (state == VCRTMPPublisherStateEnd) {
        NSLog(@"Publisher End");
    }
}
@end
