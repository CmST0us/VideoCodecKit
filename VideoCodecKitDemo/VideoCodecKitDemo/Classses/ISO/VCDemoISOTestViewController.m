//
//  VCDemoISOTestViewController.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2019/1/27.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <VideoCodecKit/VideoCodecKit.h>
#import <Masonry/Masonry.h>
#import "VCDemoISOTestViewController.h"


@interface VCDemoISOTestViewController () <VCFLVReaderDelegate, VCVideoDecoderDelegate, VCAACAudioConverterDelegate> {
    dispatch_queue_t _decodeWorkQueue;
}
@property (nonatomic, assign) BOOL playing;
@property (nonatomic, assign) BOOL seeking;

@property (nonatomic, strong) VCH264HardwareDecoder *decoder;
@property (nonatomic, strong) AVSampleBufferDisplayLayer *displayLayer;
@property (nonatomic, strong) VCAACAudioConverter *converter;
@property (nonatomic, strong) VCAudioPCMRender *render;
@property (nonatomic, strong) VCFLVReader *reader;

@property (nonatomic, strong) UISlider *timeSeekSlider;

@property (nonatomic, assign) CMTime audioTime;
@end

@implementation VCDemoISOTestViewController
- (void)timeSeekSliderDidStartSeek {
    self.seeking = YES;
    self.playing = NO;
    _audioTime = CMTimeMake(0, 0);
    [self.displayLayer flush];
    [self.render stop];
}

- (void)timeSeekSliderDidStopSeek {
    [self.render play];
    self.playing = YES;
    self.seeking = NO;
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
    _decodeWorkQueue = dispatch_queue_create("com.VideoCodecKitDemo.ISOTest.decode", DISPATCH_QUEUE_SERIAL);
    
    self.decoder = [[VCH264HardwareDecoder alloc] init];
    self.decoder.delegate = self;
    self.displayLayer = [[AVSampleBufferDisplayLayer alloc] init];
    
    self.converter = [[VCAACAudioConverter alloc] init];
    self.converter.delegate = self;
    CMTimebaseRef timeBase = nil;
    CMTimebaseCreateWithMasterClock(kCFAllocatorDefault, CMClockGetHostTimeClock(), &timeBase);
    
    [self.displayLayer setControlTimebase:timeBase];
    CFRelease(timeBase);
    
    self.displayLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.displayLayer];
    
    _reader = [[VCFLVReader alloc] initWithURL:[[NSBundle mainBundle] URLForResource:@"test" withExtension:@"flv"]];
    _reader.delegate = self;
    [_reader reCreateSeekTable];
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
    CMTime sampleBufferPts = sampleBuffer.presentationTimeStamp;
    [self.decoder decodeSampleBuffer:sampleBuffer];
    while (YES) {
        if (!_playing) {
            [NSThread sleepForTimeInterval:0.5];
            continue;
        }
        if (_audioTime.flags == kCMTimeFlags_Valid &&
            sampleBufferPts.value > _audioTime.value + 2 * _audioTime.timescale) {
            [NSThread sleepForTimeInterval:0.5];
            continue;
        }
        break;
    }
}

- (void)reader:(VCFLVReader *)reader didGetAudioSampleBuffer:(VCSampleBuffer *)sampleBuffer {
    [self.converter convertSampleBuffer:sampleBuffer];
    CMTime sampleBufferPts = sampleBuffer.presentationTimeStamp;
    while (YES) {
        if (!_playing) {
            [NSThread sleepForTimeInterval:0.5];
            continue;
        }
        if (_audioTime.flags == kCMTimeFlags_Valid &&
            sampleBufferPts.value > _audioTime.value + 2 * _audioTime.timescale) {
            [NSThread sleepForTimeInterval:0.5];
            continue;
        }
        break;
    }
}

- (void)reader:(VCFLVReader *)reader didGetVideoFormatDescription:(CMFormatDescriptionRef)formatDescription {
    NSLog(@"did get sps pps");
    [self.decoder setFormatDescription:formatDescription];
}

- (void)reader:(VCFLVReader *)reader didGetAudioFormatDescription:(CMFormatDescriptionRef)formatDescription {
    NSLog(@"get audio specific config");
    [self.converter setFormatDescription:formatDescription];
    self.render = [[VCAudioPCMRender alloc] initWithPCMFormat:[self.converter outputFormat]];
}

- (void)readerDidReachEOF:(VCFLVReader *)reader {
    
}

#pragma mark - Converter Delegate (Caller Thread) (Reader Thread)
- (void)converter:(VCAACAudioConverter *)converter didGetPCMBuffer:(AVAudioPCMBuffer *)pcmBuffer presentationTimeStamp:(CMTime)pts{
    NSLog(@"format pcm %@", pcmBuffer.format);
    CMTimeShow(pts);
    
    __weak typeof(self) weakSelf = self;
    [self.render renderPCMBuffer:pcmBuffer withPresentationTimeStamp:pts completionHandler:^{
        if (!weakSelf.seeking) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.timeSeekSlider.value = pts.value;
            });
        }
        if (weakSelf.playing) {
            weakSelf.audioTime = pts;
            CMTimebaseSetRate(weakSelf.displayLayer.controlTimebase, 1.0);
        } else {
            weakSelf.audioTime = CMTimeMake(0, 0);
        }
        CMTimebaseSetTime(weakSelf.displayLayer.controlTimebase, pts);
    }];
}

#pragma mark - Video Decoder Delegate (Decoder Delegate)
- (void)videoDecoder:(id<VCVideoDecoder>)decoder didOutputSampleBuffer:(VCSampleBuffer *)sampleBuffer {
    [self.displayLayer enqueueSampleBuffer:sampleBuffer.sampleBuffer];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.playing) {
        self.playing = NO;
        [self.render pause];
        CMTimebaseSetRate(self.displayLayer.controlTimebase, 0);
    } else {
        self.playing = YES;
        [self.render play];
        CMTimebaseSetRate(self.displayLayer.controlTimebase, 1.0);
    }
}

@end
