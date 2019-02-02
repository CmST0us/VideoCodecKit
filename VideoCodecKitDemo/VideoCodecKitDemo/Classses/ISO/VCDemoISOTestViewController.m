//
//  VCDemoISOTestViewController.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2019/1/27.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "VCDemoISOTestViewController.h"
#import <VideoCodecKit/VideoCodecKit.h>

@interface VCDemoISOTestViewController () <VCFLVReaderDelegate, VCVideoDecoderDelegate, VCAACAudioConverterDelegate> {
    dispatch_queue_t _decodeWorkQueue;
}
@property (nonatomic, strong) VCH264HardwareDecoder *decoder;
@property (nonatomic, strong) AVSampleBufferDisplayLayer *displayLayer;
@property (nonatomic, strong) VCAACAudioConverter *converter;
@property (nonatomic, strong) VCAudioPCMRender *render;
@property (nonatomic, strong) VCFLVReader *reader;
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

- (void)reader:(VCFLVReader *)reader didGetVideoSampleBuffer:(VCSampleBuffer *)sampleBuffer {
    OSStatus ret = [self.decoder decodeSampleBuffer:sampleBuffer];
    if (ret == noErr) {
        
    }
}

- (void)reader:(VCFLVReader *)reader didGetVideoFormatDescription:(CMFormatDescriptionRef)formatDescription {
    NSLog(@"did get sps pps");
    [self.decoder setFormatDescription:formatDescription];
}

- (void)reader:(VCFLVReader *)reader didGetAudioSampleBuffer:(VCSampleBuffer *)sampleBuffer {
    OSStatus ret = [self.converter convertSampleBuffer:sampleBuffer];
    if (ret != noErr) {
        NSLog(@"ERROR");
    }
}

- (void)reader:(VCFLVReader *)reader didGetAudioFormatDescription:(CMFormatDescriptionRef)formatDescription {
    NSLog(@"get audio specific config");
    [self.converter setFormatDescription:formatDescription];
    AudioStreamBasicDescription asbd = [self.converter outputFormat];
    AVAudioFormat *pcmFormat = [[AVAudioFormat alloc] initWithStreamDescription:&asbd];
    self.render = [[VCAudioPCMRender alloc] initWithPCMFormat:pcmFormat];
    [self.render play];
}

- (void)readerDidReachEOF:(VCFLVReader *)reader {
    
}

- (void)converter:(VCAACAudioConverter *)converter didGetPCMBuffer:(AVAudioPCMBuffer *)pcmBuffer presentationTimeStamp:(CMTime)pts{
    NSLog(@"format pcm %@", pcmBuffer.format);
    CMTimeShow(pts);
    [self.render renderPCMBuffer:pcmBuffer withPresentationTimeStamp:pts completionHandler:^{
        CMTimebaseSetRate(self.displayLayer.controlTimebase, 1.0);
        CMTimebaseSetTime(self.displayLayer.controlTimebase, pts);
    }];
}

- (void)videoDecoder:(id<VCVideoDecoder>)decoder didOutputSampleBuffer:(VCSampleBuffer *)sampleBuffer {
    [self.displayLayer enqueueSampleBuffer:sampleBuffer.sampleBuffer];
}

@end
