//
//  ViewController.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/8.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <KVSig/KVSig.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

#import <VideoCodecKit/VCYUV420PImage.h>
#import <VideoCodecKit/VCSampleBufferRender.h>
#import <VideoCodecKit/VCPreviewer.h>

#import "ViewController.h"
#import "VCDecodeController.h"


@interface ViewController ()
@property (nonatomic, strong) VCDecodeController *decoderController;
@property (nonatomic, assign) NSInteger decodeFrameCount;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.decoderController = [[VCDecodeController alloc] init];
    self.decoderController.previewer.watermark = 3;
    self.decoderController.previewer.previewType = VCPreviewerTypeVTLiveH264VideoOnly;
    self.decoderController.parseFilePath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"h264"];
//    self.decoderController.parseFilePath = @"/Users/cmst0us/Desktop/test.h264";
    [self setupDisplayLayer];
    [self bindData];
}

- (void)setupDisplayLayer {
    [self.decoderController.previewer.render attachToLayer:self.view.layer];
}

- (void)bindData {
    weakSelf(target);
    [self.decoderController addKVSigObserver:self forKeyPath:KVSKeyPath([self decoderController].previewer.decoder.fps) handle:^(NSObject *oldValue, NSObject *newValue) {
        if (newValue != nil && [newValue isKindOfClass:[NSNumber class]]) {
            NSNumber *fpsNumber = (NSNumber *)newValue;
            target.decoderController.previewer.fps = [fpsNumber integerValue];
        }
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    if ([self.decoderController.previewer.decoder.currentState isEqualToNumber:@(VCBaseCodecStateRunning)]) {
        [self.decoderController stopParse];
    } else if ([self.decoderController.previewer.decoder.currentState isEqualToNumber:@(VCBaseCodecStateStop)]) {
        [self.decoderController startParse];
    } else if ([self.decoderController.previewer.decoder.currentState isEqualToNumber:@(VCBaseCodecStateInit)]) {
        [self.decoderController startParse];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.decoderController stopParse];
//        [NSThread sleepForTimeInterval:1];
//        [self.decoderController.parser reset];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
