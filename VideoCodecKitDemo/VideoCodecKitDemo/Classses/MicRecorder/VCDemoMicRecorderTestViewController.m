//
//  VCDemoMicRecorderTestViewController.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2019/2/7.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <VideoCodecKit/VideoCodecKit.h>
#import "VCDemoMicRecorderTestViewController.h"

@interface VCDemoMicRecorderTestViewController ()
@property (nonatomic, strong) VCMicRecorder *recorder;
@property (nonatomic, strong) VCAudioPCMRender *render;
@end

@implementation VCDemoMicRecorderTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.recorder = [[VCMicRecorder alloc] initWithOutputFormat:[VCAudioConverter PCMFormatWithSampleRate:44100 channels:2]];
    self.render = [[VCAudioPCMRender alloc] initWithPCMFormat:self.recorder.outputFormat];
    [self.render play];
}

- (void)viewDidAppear:(BOOL)animated {
    __weak typeof(self) weakSelf = self;
    [self.recorder startRecoderWithBlock:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        AVAudioFormat *format = buffer.format;
        AudioStreamBasicDescription *desc = format.streamDescription;
        AudioBufferList *list = buffer.audioBufferList;
        [weakSelf.render renderPCMBuffer:buffer withPresentationTimeStamp:kCMTimeZero completionHandler:nil];
    }];
}

@end
