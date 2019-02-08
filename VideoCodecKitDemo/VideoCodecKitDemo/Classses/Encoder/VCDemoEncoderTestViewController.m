//
//  VCDemoEncoderTestViewController.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2019/2/5.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <VideoCodecKit/VideoCodecKit.h>
#import "VCDemoEncoderTestViewController.h"

@interface VCDemoEncoderTestViewController () <VCAudioConverterDelegate>
@property (nonatomic, strong) VCAudioConverter *converter;
@property (nonatomic, strong) VCMicRecorder *recorder;
@end

@implementation VCDemoEncoderTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    AVAudioFormat *sourceFormat = [VCAudioConverter PCMFormatWithSampleRate:44100 channels:2];
    self.recorder = [[VCMicRecorder alloc] initWithOutputFormat:sourceFormat];
    self.converter = [[VCAudioConverter alloc] initWithOutputFormat:[VCAudioConverter AACFormatWithSampleRate:sourceFormat.sampleRate formatFlags:kMPEG4Object_AAC_LC channels:sourceFormat.channelCount] sourceFormat:sourceFormat];
    self.converter.delegate = self;
    
    [self.recorder startRecoderWithBlock:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [weakSelf.converter convertAudioBufferList:buffer.mutableAudioBufferList presentationTimeStamp:CMTimeMake(when.sampleTime, when.sampleRate)];
    }];
}

- (void)onBack:(UIButton *)button {
    [self.recorder stop];
    [super onBack:button];
}

- (void)converter:(VCAudioConverter *)converter didOutputAudioBuffer:(AVAudioBuffer *)audioBuffer presentationTimeStamp:(CMTime)pts {
    NSLog(@"audioBuffer %@", audioBuffer);
}
@end

