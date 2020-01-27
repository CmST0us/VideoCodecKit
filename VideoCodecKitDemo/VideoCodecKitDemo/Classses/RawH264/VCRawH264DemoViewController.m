//
//  VCRawH264DemoViewController.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2020/1/27.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import <VideoCodecKit/VideoCodecKit.h>
#import "VCRawH264DemoViewController.h"


@interface VCRawH264DemoViewController () <VCAssetReaderDelegate, VCVideoDecoderDelegate>
@property (nonatomic, strong) VCRawH264Reader *reader;
@property (nonatomic, strong) VCH264HardwareDecoder *decoder;
@property (nonatomic, strong) AVSampleBufferDisplayLayer *displayLayer;
@property (nonatomic, strong) CADisplayLink *displayLink;
@end

@implementation VCRawH264DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSURL *file = [[NSBundle mainBundle] URLForResource:@"sss" withExtension:@"h264"];
    self.reader = [[VCRawH264Reader alloc] initWithURL:file];
    self.reader.delegate = self;
    [self.reader startReading];
    
    self.decoder = [[VCH264HardwareDecoder alloc] init];
    self.decoder.delegate = self;
    
    self.displayLayer = [[AVSampleBufferDisplayLayer alloc] init];
    [self.view.layer addSublayer:self.displayLayer];
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplayLink)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)viewDidAppear:(BOOL)animated {
    self.displayLayer.frame = self.view.bounds;
}

- (void)handleDisplayLink {
    [self.reader next];
}

- (void)videoDecoder:(id<VCVideoDecoder>)decoder didOutputSampleBuffer:(VCSampleBuffer *)sampleBuffer {
    NSLog(@"SampleBuffer :%@", sampleBuffer.sampleBuffer);
    [self.displayLayer enqueueSampleBuffer:sampleBuffer.sampleBuffer];
}

- (void)reader:(VCAssetReader *)reader didGetVideoSampleBuffer:(VCSampleBuffer *)sampleBuffer {
    [self.decoder decodeSampleBuffer:sampleBuffer];
}

- (void)reader:(VCAssetReader *)reader didGetVideoFormatDescription:(CMFormatDescriptionRef)formatDescription {
    [self.decoder setFormatDescription:formatDescription];
}

@end
