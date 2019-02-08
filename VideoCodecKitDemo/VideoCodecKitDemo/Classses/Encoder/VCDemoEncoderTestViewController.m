//
//  VCDemoEncoderTestViewController.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2019/2/5.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <VideoCodecKit/VideoCodecKit.h>
#import "VCDemoEncoderTestViewController.h"

@interface VCDemoEncoderTestViewController () <VCVideoEncoderDelegate, VCVideoDecoderDelegate, VCFLVReaderDelegate, VCAudioConverterDelegate>
@property (nonatomic, strong) VCFLVReader *reader;
@property (nonatomic, strong) VCH264HardwareDecoder *decoder;
@property (nonatomic, strong) VCH264HardwareEncoder *encoder;
@property (nonatomic, strong) VCAudioConverter *converter;
@property (nonatomic, strong) VCMicRecorder *recorder;
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
    
    __weak typeof(self) weakSelf = self;
    // [Bug]: 注意这里需要指定声道为1
    // 不然会出现AudioBufferList mNumberBuffers = 2, 实际上只有一个通道数据的情况
    // 如果使用[AVAudioInputNode outputFormat]也会出现这样的情况
    AVAudioFormat *sourceFormat = [VCAudioConverter PCMFormatWithSampleRate:44100 channels:2];
    self.recorder = [[VCMicRecorder alloc] initWithOutputFormat:sourceFormat];
    self.converter = [[VCAudioConverter alloc] initWithOutputFormat:[VCAudioConverter AACFormatWithSampleRate:sourceFormat.sampleRate formatFlags:kMPEG4Object_AAC_LC channels:sourceFormat.channelCount] sourceFormat:sourceFormat];
    self.converter.delegate = self;
    [self.recorder startRecoderWithBlock:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [weakSelf.converter convertAudioBufferList:buffer.mutableAudioBufferList presentationTimeStamp:CMTimeMake(when.sampleTime, when.sampleRate)];
    }];
}

- (void)videoEncoder:(id<VCVideoEncoder>)encoder didOutputSampleBuffer:(VCSampleBuffer *)sampleBuffer {
    NSLog(@"output sampleBuffer");
    if (sampleBuffer.keyFrame) {
        NSData *parameterSetData = sampleBuffer.h264ParameterSetData;
        [self.fileWriterStream write:parameterSetData.bytes maxLength:parameterSetData.length];
    }
    
    NSData *dataBuffer = sampleBuffer.dataBufferData;
    VCAVCFormatStream *avcStream = [[VCAVCFormatStream alloc] initWithData:dataBuffer startCodeLength:4];
    dataBuffer = [avcStream toAnnexBFormatData].data;
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
//    OSStatus ret = [self.decoder decodeSampleBuffer:sampleBuffer];
//    if (ret != noErr) {
//        return;
//    }
}

- (void)reader:(VCFLVReader *)reader didGetAudioFormatDescription:(CMFormatDescriptionRef)formatDescription {
    
}

- (void)reader:(VCFLVReader *)reader didGetVideoFormatDescription:(CMFormatDescriptionRef)formatDescription {
    [self.decoder setFormatDescription:formatDescription];
}

- (void)converter:(VCAudioConverter *)converter didOutputAudioBuffer:(AVAudioBuffer *)audioBuffer presentationTimeStamp:(CMTime)pts {
    NSLog(@"audioBuffer %@", audioBuffer);
}
@end

