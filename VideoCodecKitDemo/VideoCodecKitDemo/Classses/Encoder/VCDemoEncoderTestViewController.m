//
//  VCDemoEncoderTestViewController.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2019/2/5.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <VideoCodecKit/VideoCodecKit.h>
#import "VCDemoEncoderTestViewController.h"

@interface VCDemoEncoderTestViewController () <VCAudioConverterDelegate>
@property (nonatomic, strong) VCAudioConverter *converter;
@property (nonatomic, strong) VCAudioSpecificConfig *config;
@property (nonatomic, strong) VCMicRecorder *recorder;
@property (nonatomic, strong) NSFileHandle *file;
@end

@implementation VCDemoEncoderTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    self.recorder = [[VCMicRecorder alloc] init];
    AVAudioFormat *sourceFormat = self.recorder.outputFormat;
    self.converter = [[VCAudioConverter alloc] initWithOutputFormat:[VCAudioConverter AACFormatWithSampleRate:sourceFormat.sampleRate formatFlags:kMPEG4Object_AAC_LC channels:sourceFormat.channelCount] sourceFormat:sourceFormat];
    self.converter.delegate = self;
    self.config = self.converter.audioSpecificConfig;
    
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *filePath = [path stringByAppendingPathComponent:@"test.aac"];
    NSLog(@"file: %@", filePath);
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    self.file = [NSFileHandle fileHandleForWritingAtPath:filePath];
    [self.recorder startRecoderWithBlock:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [weakSelf.converter convertAudioBufferList:buffer.mutableAudioBufferList presentationTimeStamp:CMTimeMake(when.sampleTime, when.sampleRate)];
    }];
}

- (void)onBack:(UIButton *)button {
    [self.recorder stop];
    [super onBack:button];
}

- (void)converter:(VCAudioConverter *)converter didOutputAudioBuffer:(AVAudioBuffer *)audioBuffer presentationTimeStamp:(CMTime)pts {
    AVAudioCompressedBuffer *buffer = (AVAudioCompressedBuffer *)audioBuffer;
    NSData *data = [self.config adtsDataForPacketLength:buffer.byteLength];
    VCByteArray *array = [[VCByteArray alloc] initWithData:data];
    [array writeBytes:[NSData dataWithBytes:buffer.data length:buffer.byteLength]];
    [self.file writeData:array.data]; 
}
@end

