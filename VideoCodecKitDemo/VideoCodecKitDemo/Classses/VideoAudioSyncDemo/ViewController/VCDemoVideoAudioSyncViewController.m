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


#define kVCDemoVideoAudioSyncReadBufferSize (4096)

@interface VCDemoVideoAudioSyncViewController () <VCBaseFrameParserDelegate>
@property (nonatomic, strong) NSThread *feedThread;
@property (nonatomic, strong) VCAudioFrameParser *parser;
@property (nonatomic, strong) NSInputStream *inputStream;
@end

@implementation VCDemoVideoAudioSyncViewController

- (void)customInit {
    [super customInit];
    
    self.parser = [[VCAudioFrameParser alloc] initWithAudioType:kAudioFileAAC_ADTSType];
    self.parser.delegate = self;
    
    NSString *aacFilePath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"aac"];
    self.inputStream = [[NSInputStream alloc] initWithFileAtPath:aacFilePath];
    [self.inputStream open];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"did load");
    self.feedThread = [[NSThread alloc] initWithTarget:self selector:@selector(workThread) object:nil];
    [self.feedThread start];
}


- (void)workThread {
    void *readBuffer = malloc(kVCDemoVideoAudioSyncReadBufferSize);
    while (![[NSThread currentThread] isCancelled]) {
        @autoreleasepool {
            ssize_t readLen = 0;
            readLen = [self.inputStream read:readBuffer maxLength:kVCDemoVideoAudioSyncReadBufferSize];
            if (readLen > 0) {
                if ([self.parser parseData:readBuffer length:readLen] < 0) {
                    free(readBuffer);
                }
            } else {
                free(readBuffer);
                break;
            }
        }
    }
}
- (void)onBack:(UIButton *)button {
    [super onBack:button];
    [self.feedThread cancel];
}

- (void)frameParserDidParseFrame:(VCBaseFrame *)aFrame {
    
}

@end
