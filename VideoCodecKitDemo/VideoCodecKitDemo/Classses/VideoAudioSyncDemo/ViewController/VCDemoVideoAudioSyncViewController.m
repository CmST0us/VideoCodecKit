//
//  VCDemoVideoAudioSyncViewController.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/11/6.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import <VideoCodecKit/VideoCodecKit.h>
#import "VCDemoVideoAudioSyncViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface VCDemoVideoAudioSyncViewController ()
@property (nonatomic, strong) AVURLAsset *asset;
@property (nonatomic, strong) AVAssetReader *assetReader;
@property (nonatomic, strong) AVAssetReaderTrackOutput *trackOutput;
@property (nonatomic, strong) VCAUAACAudioDecoder *decoder;
@property (nonatomic, strong) VCAUAACAudioDecoderConfig *config;
@property (nonatomic, strong) NSThread *feedThread;
@end

@implementation VCDemoVideoAudioSyncViewController

- (void)customInit {
    [super customInit];
    NSError *err = nil;
    
    self.asset = [[AVURLAsset alloc] initWithURL:[[NSBundle mainBundle] URLForResource:@"test" withExtension:@"aac"]
                                         options:@{
                                                   AVURLAssetPreferPreciseDurationAndTimingKey: @(YES)
                                                   }];
    self.assetReader = [[AVAssetReader alloc] initWithAsset:self.asset error:&err];
    NSArray<AVAssetTrack *> *audioTracks = [self.asset tracksWithMediaType:AVMediaTypeAudio];
    
    NSDictionary *outputSetting = @{
                                    AVFormatIDKey: @(kAudioFormatLinearPCM),
                                    AVLinearPCMBitDepthKey: @(16),
                                    AVLinearPCMIsBigEndianKey: @(NO),
                                    AVLinearPCMIsFloatKey: @(NO),
                                    AVLinearPCMIsNonInterleaved: @(YES),
                                    AVSampleRateKey: @(44100.0),
                                    AVNumberOfChannelsKey: @(1),
                                    };
    
    self.trackOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTracks[0] outputSettings:outputSetting];
    self.trackOutput.alwaysCopiesSampleData = NO;
    [self.assetReader addOutput:self.trackOutput];
    [self.assetReader startReading];
    NSArray *formatDesc = audioTracks[0].formatDescriptions;
    for(unsigned int i = 0; i < [formatDesc count]; ++i) {
        CMAudioFormatDescriptionRef item = (__bridge_retained CMAudioFormatDescriptionRef)[formatDesc objectAtIndex:i];
        const AudioStreamBasicDescription* fmtDesc = CMAudioFormatDescriptionGetStreamBasicDescription(item);
        if (fmtDesc) {
            VCAUAACAudioDecoderConfig *c = [[VCAUAACAudioDecoderConfig alloc] initWithAudioStramBasicDescription:*fmtDesc];
            NSLog(@"%@", c);
            self.config = [[VCAUAACAudioDecoderConfig alloc] init];
        }
        CFRelease(item);
    }
    
    self.decoder = [[VCAUAACAudioDecoder alloc] initWithConfig:self.config];
    [self.decoder setup];
    [self.decoder run];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"did load");
    self.feedThread = [[NSThread alloc] initWithTarget:self selector:@selector(workThread) object:nil];
    [self.feedThread start];
}


- (void)workThread {
    while (![[NSThread currentThread] isCancelled]) {
        @autoreleasepool {
            CMSampleBufferRef sampleBuffer = [self.trackOutput copyNextSampleBuffer];
            CMBlockBufferRef blockBuffer;
            size_t bufferListSizeNeededOut = 0;
            if (!sampleBuffer) {
                break;
            }
            AudioBufferList audioBufferList;
            OSStatus err = CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer,
                                                                                   &bufferListSizeNeededOut,
                                                                                   &audioBufferList,
                                                                                   sizeof(audioBufferList),
                                                                                   kCFAllocatorSystemDefault,
                                                                                   kCFAllocatorSystemDefault,
                                                                                   kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment,
                                                                                   &blockBuffer);
            if (err) {
                NSLog(@"CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer error: %d", (int)err);
            }
            
            CMTime presentationTimeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            int timeStamp = (1000 * (int)presentationTimeStamp.value) / presentationTimeStamp.timescale;
            NSLog(@"audio timestamp %d", timeStamp);
            CFRelease(sampleBuffer);
            
            for (int i = 0; i < audioBufferList.mNumberBuffers; ++i) {
                VCAudioFrame *audioFrame = [[VCAudioFrame alloc] init];
                [audioFrame createParseDataWithSize:audioBufferList.mBuffers[i].mDataByteSize];
                memcpy(audioFrame.parseData, audioBufferList.mBuffers[i].mData, audioBufferList.mBuffers[i].mDataByteSize);
                audioFrame.numberChannels = audioBufferList.mBuffers[i].mNumberChannels;
                [self.decoder decodeWithFrame:audioFrame];
            }
        }
    }
}
- (void)onBack:(UIButton *)button {
    [super onBack:button];
    [self.feedThread cancel];
    [self.decoder invalidate];
}

@end
