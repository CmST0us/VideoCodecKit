//
//  VCDemoISOTestViewController.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2019/1/27.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <VideoCodecKit/VideoCodecKit.h>
#import "VCDemoISOTestViewController.h"


@interface VCDemoISOTestViewController () <VCFLVReaderDelegate, VCVideoDecoderDelegate, VCAACAudioConverterDelegate> {
    dispatch_queue_t _decodeWorkQueue;
}
@property (nonatomic, strong) VCH264HardwareDecoder *decoder;
@property (nonatomic, strong) AVSampleBufferDisplayLayer *displayLayer;
@property (nonatomic, strong) VCAACAudioConverter *converter;
@property (nonatomic, strong) VCAudioPCMRender *render;
@property (nonatomic, strong) VCFLVReader *reader;

@property (nonatomic, assign) CMTime audioTime;
@end

@implementation VCDemoISOTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    [_reader starAsyncRead];
    
}

- (void)onBack:(UIButton *)button {
    [super onBack:button];
    [self.render stop];
}

#pragma mark - Reader Delegate (Reader Threader)
- (void)reader:(VCFLVReader *)reader didGetVideoSampleBuffer:(VCSampleBuffer *)sampleBuffer {
    CMTime sampleBufferPts = sampleBuffer.presentationTimeStamp;
    while (_audioTime.flags == kCMTimeFlags_Valid &&
           sampleBufferPts.value > _audioTime.value + 2 * _audioTime.timescale) {
        [NSThread sleepForTimeInterval:1];
    }
    [self.decoder decodeSampleBuffer:sampleBuffer];
}

- (void)reader:(VCFLVReader *)reader didGetAudioSampleBuffer:(VCSampleBuffer *)sampleBuffer {
    CMTime sampleBufferPts = sampleBuffer.presentationTimeStamp;
    while (_audioTime.flags == kCMTimeFlags_Valid &&
           sampleBufferPts.value > _audioTime.value + 2 * _audioTime.timescale) {
        [NSThread sleepForTimeInterval:1];
    }
    [self.converter convertSampleBuffer:sampleBuffer];
}

- (void)reader:(VCFLVReader *)reader didGetVideoFormatDescription:(CMFormatDescriptionRef)formatDescription {
    NSLog(@"did get sps pps");
    [self.decoder setFormatDescription:formatDescription];
}

- (void)reader:(VCFLVReader *)reader didGetAudioFormatDescription:(CMFormatDescriptionRef)formatDescription {
    NSLog(@"get audio specific config");
    [self.converter setFormatDescription:formatDescription];
    self.render = [[VCAudioPCMRender alloc] initWithPCMFormat:[self.converter outputFormat]];
    [self.render play];
}

- (void)readerDidReachEOF:(VCFLVReader *)reader {
    
}

#pragma mark - Converter Delegate (Caller Thread) (Reader Thread)
- (void)converter:(VCAACAudioConverter *)converter didGetPCMBuffer:(AVAudioPCMBuffer *)pcmBuffer presentationTimeStamp:(CMTime)pts{
    NSLog(@"format pcm %@", pcmBuffer.format);
    CMTimeShow(pts);
    
    __weak typeof(self) weakSelf = self;
    [self.render renderPCMBuffer:pcmBuffer withPresentationTimeStamp:pts completionHandler:^{
        weakSelf.audioTime = pts;
        CMTimebaseSetRate(self.displayLayer.controlTimebase, 1.0);
        CMTimebaseSetTime(self.displayLayer.controlTimebase, pts);
    }];
}

#pragma mark - Video Decoder Delegate (Decoder Delegate)
- (void)videoDecoder:(id<VCVideoDecoder>)decoder didOutputSampleBuffer:(VCSampleBuffer *)sampleBuffer {
    [self.displayLayer enqueueSampleBuffer:sampleBuffer.sampleBuffer];
}

@end
