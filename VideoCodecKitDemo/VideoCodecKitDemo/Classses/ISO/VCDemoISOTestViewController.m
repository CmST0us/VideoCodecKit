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
    
    VCFLVReader *reader = [[VCFLVReader alloc] initWithURL:[NSURL fileURLWithPath:@"/Users/cmst0us/Desktop/test_.flv"]];
    reader.delegate = self;
    [reader starAsyncRead];
    
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
    CMTime audioTime = sampleBuffer.presentationTimeStamp;
    [self.converter convertSampleBuffer:sampleBuffer];
}

- (void)reader:(VCFLVReader *)reader didGetAudioFormatDescription:(CMFormatDescriptionRef)formatDescription {
    NSLog(@"get audio specific config");
    CMTimebaseSetRate(self.displayLayer.controlTimebase, 1.0);
    [self.converter setFormatDescription:formatDescription];
}

- (void)videoDecoder:(id<VCVideoDecoder>)decoder didOutputSampleBuffer:(VCSampleBuffer *)sampleBuffer {
//    [self.displayLayer enqueueSampleBuffer:sampleBuffer.sampleBuffer];
}

- (void)converter:(VCAACAudioConverter *)converter didGetPCMBuffer:(AVAudioPCMBuffer *)pcmBuffer presentationTimeStamp:(CMTime)pts{
    NSLog(@"get buffer %@", pcmBuffer);
    CMTimeShow(pts);
}

@end
