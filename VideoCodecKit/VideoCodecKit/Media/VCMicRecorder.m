//
//  VCMicRecorder.m
//  VideoCodecKit
//
//  Created by CmST0us on 2019/2/7.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "VCMicRecorder.h"

@interface VCMicRecorder ()
@property (nonatomic, strong) AVAudioEngine *engine;
@end

@implementation VCMicRecorder

- (instancetype)init {
    self = [super init];
    if (self) {
        _engine = [[AVAudioEngine alloc] init];
        _recording = NO;
        _sampleRate = 48000;
        _channelCount = 2;
    }
    return self;
}

- (AVAudioFormat *)outputFormat {
    AVAudioFormat *pcmFormat = [[AVAudioFormat alloc] initWithCommonFormat:AVAudioPCMFormatInt16 sampleRate:self.sampleRate channels:self.channelCount interleaved:NO];
    return pcmFormat;
}

- (AVAudioFormat *)nodeFormat {
    return [self.engine.inputNode outputFormatForBus:0];
}

- (BOOL)startRecoderWithFormat:(AVAudioFormat *)format
                         block:(AVAudioNodeTapBlock)block {
    if (_recording) return NO;
    
    AVAudioInputNode *input = [self.engine inputNode];
    [input installTapOnBus:0 bufferSize:4096 format:format block:block];
    NSError *err = nil;
    [self.engine startAndReturnError:&err];
    if (err == nil) {
        _recording = YES;
        return YES;
    }
    _recording = NO;
    return NO;
}

- (void)stop {
    [self.engine.inputNode removeTapOnBus:0];
    _recording = NO;
}

@end
