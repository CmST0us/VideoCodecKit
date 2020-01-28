//
//  VCDemoFLVAudioPlayTestViewController.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2019/2/8.
//  Copyright © 2019 eric3u. All rights reserved.
//
#import <VideoCodecKit/VideoCodecKit.h>
#import "VCDemoFLVAudioPlayTestViewController.h"

@interface VCDemoFLVAudioPlayTestViewController () <VCAssetReaderDelegate, VCAudioConverterDelegate> {
}
@property (nonatomic, assign) BOOL playing;
@property (nonatomic, assign) BOOL seeking;

@property (nonatomic, strong) NSCondition *readerConsumeCondition;

@property (nonatomic, strong) VCAudioConverter *converter;
@property (nonatomic, strong) VCAudioPCMRender *render;
@property (nonatomic, strong) VCFLVReader *reader;

@property (nonatomic, strong) UISlider *timeSeekSlider;

@property (nonatomic, assign) CMTime audioTime;
@end

@implementation VCDemoFLVAudioPlayTestViewController
- (void)timeSeekSliderDidStartSeek {
    self.seeking = YES;
    self.playing = NO;
    _audioTime = CMTimeMake(0, 0);
    [self.render stop];
}

- (void)timeSeekSliderDidStopSeek {
    [self.render play];
    self.playing = YES;
    self.seeking = NO;
    [self.readerConsumeCondition broadcast];
}

- (void)timeSeekSliderValueDidChange {
    [_reader seekToTime:CMTimeMake(self.timeSeekSlider.value, 1000)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // UI
    self.timeSeekSlider = [[UISlider alloc] init];
    [self.view addSubview:self.timeSeekSlider];
    [self.timeSeekSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-44);
    }];
    [self.timeSeekSlider addTarget:self action:@selector(timeSeekSliderValueDidChange) forControlEvents:UIControlEventValueChanged];
    [self.timeSeekSlider addTarget:self action:@selector(timeSeekSliderDidStartSeek) forControlEvents:UIControlEventTouchDown];
    [self.timeSeekSlider addTarget:self action:@selector(timeSeekSliderDidStopSeek) forControlEvents:UIControlEventTouchUpInside];
    
    // Comopnent
    _playing = NO;
    _readerConsumeCondition = [[NSCondition alloc] init];

    self.converter = [[VCAudioConverter alloc] init];
    self.converter.delegate = self;
    
    _reader = [[VCFLVReader alloc] initWithURL:[[NSBundle mainBundle] URLForResource:@"test_flv_audio" withExtension:@"flv"]];
    _reader.delegate = self;
    [_reader createSeekTable];
    [_reader starAsyncReading];
    self.timeSeekSlider.minimumValue = 0;
    self.timeSeekSlider.maximumValue = _reader.duration.value;
}

- (void)onBack:(UIButton *)button {
    [super onBack:button];
    [self.render stop];
}

#pragma mark - Reader Delegate (Reader Threader)
- (void)reader:(VCFLVReader *)reader didGetVideoSampleBuffer:(VCSampleBuffer *)sampleBuffer {

}

- (void)reader:(VCFLVReader *)reader didGetAudioSampleBuffer:(VCSampleBuffer *)sampleBuffer {
    [self.converter convertSampleBuffer:sampleBuffer];
    CMTime sampleBufferPts = sampleBuffer.presentationTimeStamp;
    while (YES) {
        if (!_playing) {
            [self.readerConsumeCondition waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.5]];
            if ([[NSThread currentThread] isCancelled]) break;
            continue;
        }
        if (_audioTime.flags == kCMTimeFlags_Valid &&
            sampleBufferPts.value > _audioTime.value + 3 * _audioTime.timescale) {
            [self.readerConsumeCondition waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.5]];
            if ([[NSThread currentThread] isCancelled]) break;
            continue;
        }
        break;
    }
}

- (void)reader:(VCFLVReader *)reader didGetVideoFormatDescription:(CMFormatDescriptionRef)formatDescription {
    
}

- (void)reader:(VCFLVReader *)reader didGetAudioFormatDescription:(CMFormatDescriptionRef)formatDescription {
    self.converter.sourceFormat = [VCAudioConverter formatWithCMAudioFormatDescription:formatDescription];
    self.converter.outputFormat = [VCAudioConverter PCMFormatWithSampleRate:self.converter.sourceFormat.sampleRate channels:self.converter.sourceFormat.channelCount];
    self.render = [[VCAudioPCMRender alloc] initWithPCMFormat:[self.converter outputFormat]];
}

- (void)readerDidReachEOF:(VCFLVReader *)reader {
    
}

#pragma mark - Converter Delegate (Caller Thread) (Reader Thread)
- (void)converter:(VCAudioConverter *)converter didOutputAudioBuffer:(AVAudioBuffer *)audioBuffer presentationTimeStamp:(CMTime)pts {
    if (![audioBuffer isKindOfClass:[AVAudioPCMBuffer class]]) return;
    __weak typeof(self) weakSelf = self;
    [self.render renderPCMBuffer:(AVAudioPCMBuffer *)audioBuffer withPresentationTimeStamp:pts completionHandler:^{
        if (!weakSelf.seeking) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.timeSeekSlider.value = pts.value;
            });
        }
        if (weakSelf.playing) {
            weakSelf.audioTime = pts;
        } else {
            weakSelf.audioTime = CMTimeMake(0, 0);
        }
    }];
}

#pragma mark - Video Decoder Delegate (Decoder Delegate)
- (void)videoDecoder:(id<VCVideoDecoder>)decoder didOutputSampleBuffer:(VCSampleBuffer *)sampleBuffer {
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.playing) {
        self.playing = NO;
        [self.render pause];
    } else {
        self.playing = YES;
        [self.render play];
    }
    [self.readerConsumeCondition broadcast];
}

@end
