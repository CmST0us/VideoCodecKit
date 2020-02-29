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

@property (nonatomic, strong) dispatch_queue_t fileQueue;
@property (nonatomic, assign) BOOL canWrite;
@end

@implementation VCDemoEncoderTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    self.recorder = [[VCMicRecorder alloc] init];
    self.recorder.sampleRate = 48000;
    self.recorder.channelCount = 1;
    AVAudioFormat *sourceFormat = self.recorder.outputFormat;
    self.converter = [[VCAudioConverter alloc] initWithOutputFormat:[VCAudioConverter AACFormatWithSampleRate:sourceFormat.sampleRate channels:1] sourceFormat:sourceFormat delegateQueue:dispatch_get_global_queue(0, 0)];
    self.converter.delegate = self;
    self.converter.bitrate = 192000;
    self.converter.audioConverterQuality = kAudioConverterQuality_High;
    self.config = self.converter.outputAudioSpecificConfig;
    
    self.fileQueue = dispatch_queue_create("FILEQUEUE", DISPATCH_QUEUE_SERIAL);
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *filePath = [path stringByAppendingPathComponent:@"test.aac"];
    NSLog(@"file: %@", filePath);
    self.canWrite = YES;
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    self.file = [NSFileHandle fileHandleForWritingAtPath:filePath];
    [self.recorder startRecoderWithFormat:self.recorder.outputFormat
                                    block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
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
    VCByteArray *array = [[VCByteArray alloc] init];
    [array writeBytes:data];
    [array writeBytes:[NSData dataWithBytes:buffer.data length:buffer.byteLength]];
    dispatch_async(self.fileQueue, ^{
        if (self.canWrite) {
            [self.file writeData:array.data];
        }
    });
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    dispatch_async(self.fileQueue, ^{
        [self.file closeFile];
        self.canWrite = NO;
    });
}
@end

