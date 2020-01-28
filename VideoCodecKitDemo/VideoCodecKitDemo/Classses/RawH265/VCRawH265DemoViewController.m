//
//  VCRawH265DemoViewController.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2020/1/27.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import <VideoCodecKit/VideoCodecKit.h>
#import "VCRawH265DemoViewController.h"


@interface VCRawH265DemoViewController () <VCAssetReaderDelegate, VCVideoDecoderDelegate>
@property (nonatomic, strong) VCRawH265Reader *reader;
@property (nonatomic, strong) VCH265HardwareDecoder *decoder;
@property (nonatomic, strong) AVSampleBufferDisplayLayer *displayLayer;
@end

@implementation VCRawH265DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSURL *file = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"h265"];
    self.reader = [[VCRawH265Reader alloc] initWithURL:file];
    self.reader.delegate = self;
    [self.reader startReading];
    
    self.decoder = [[VCH265HardwareDecoder alloc] init];
    self.decoder.delegate = self;
    
    self.displayLayer = [[AVSampleBufferDisplayLayer alloc] init];
    [self.view.layer addSublayer:self.displayLayer];
    
}

- (void)viewDidAppear:(BOOL)animated {
    self.displayLayer.frame = self.view.bounds;
}

- (void)videoDecoder:(id<VCVideoDecoder>)decoder didOutputSampleBuffer:(VCSampleBuffer *)sampleBuffer {
    [self.displayLayer enqueueSampleBuffer:sampleBuffer.sampleBuffer];
}

- (void)reader:(VCAssetReader *)reader didGetVideoSampleBuffer:(VCSampleBuffer *)sampleBuffer {
    [self.decoder decodeSampleBuffer:sampleBuffer];
    [NSThread sleepForTimeInterval:0.016];
}

- (void)reader:(VCAssetReader *)reader didGetVideoFormatDescription:(CMFormatDescriptionRef)formatDescription {
    [self.decoder setFormatDescription:formatDescription];
}

@end
