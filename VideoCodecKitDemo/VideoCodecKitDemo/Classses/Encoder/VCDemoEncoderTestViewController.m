//
//  VCDemoEncoderTestViewController.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2019/2/5.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <VideoCodecKit/VideoCodecKit.h>
#import "VCDemoEncoderTestViewController.h"

@interface VCDemoEncoderTestViewController () <VCVideoEncoderDelegate, VCVideoDecoderDelegate, VCFLVReaderDelegate>
@property (nonatomic, strong) VCFLVReader *reader;
@property (nonatomic, strong) VCH264HardwareDecoder *decoder;
@property (nonatomic, strong) VCH264HardwareEncoder *encoder;
@property (nonatomic, strong) NSOutputStream *fileWriterStream;
@end

@implementation VCDemoEncoderTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.encoder = [[VCH264HardwareEncoder alloc] init];
    self.encoder.delegate = self;
    
    self.decoder = [[VCH264HardwareDecoder alloc] init];
    self.decoder.delegate = self;
    
    self.reader = [[VCFLVReader alloc] initWithURL:[[NSBundle mainBundle] URLForResource:@"test" withExtension:@"flv"]];
    self.reader.delegate = self;
    [self.reader starAsyncReading];
    
    self.fileWriterStream = [[NSOutputStream alloc] initWithURL:[NSURL fileURLWithPath:@"/Users/cmst0us/Desktop/abc.h264"] append:NO];
    [self.fileWriterStream open];
}

- (void)videoEncoder:(id<VCVideoEncoder>)encoder didOutputSampleBuffer:(VCSampleBuffer *)sampleBuffer {
    NSLog(@"output sampleBuffer");
    if (sampleBuffer.keyFrame) {
        NSData *parameterSetData = sampleBuffer.h264ParameterSetData;
        [self.fileWriterStream write:parameterSetData.bytes maxLength:parameterSetData.length];
    }
    NSData *dataBuffer = sampleBuffer.dataBufferData;
    [self.fileWriterStream write:dataBuffer.bytes maxLength:dataBuffer.length];
}

- (void)videoEncoder:(id<VCVideoEncoder>)encoder didOutputFormatDescription:(CMFormatDescriptionRef)description {
    NSLog(@"format description: %@", description);
}

- (void)videoDecoder:(id<VCVideoDecoder>)decoder didOutputSampleBuffer:(VCSampleBuffer *)sampleBuffer {
    OSStatus ret = [self.encoder encodeSampleBuffer:sampleBuffer];
    if (ret != noErr) {
        return;
    }
}

#pragma mark - Reader
- (void)reader:(VCFLVReader *)reader didGetAudioSampleBuffer:(VCSampleBuffer *)sampleBuffer {
    
}

- (void)reader:(VCFLVReader *)reader didGetVideoSampleBuffer:(VCSampleBuffer *)sampleBuffer {
    OSStatus ret = [self.decoder decodeSampleBuffer:sampleBuffer];
    if (ret != noErr) {
        return;
    }
}

- (void)reader:(VCFLVReader *)reader didGetAudioFormatDescription:(CMFormatDescriptionRef)formatDescription {
    
}

- (void)reader:(VCFLVReader *)reader didGetVideoFormatDescription:(CMFormatDescriptionRef)formatDescription {
    [self.decoder setFormatDescription:formatDescription];
}

@end

