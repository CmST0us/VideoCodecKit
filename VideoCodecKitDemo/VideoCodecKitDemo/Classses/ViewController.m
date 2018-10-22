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
#import "VCEncoderController.h"

@interface ViewController ()
@property (nonatomic, strong) VCDecodeController *decoderController;
@property (nonatomic, strong) VCEncoderController *encoderController;
@property (nonatomic, assign) NSInteger decodeFrameCount;
@property (nonatomic, strong) UITapGestureRecognizer *playGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *stopGestureRecognizer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.decoderController = [[VCDecodeController alloc] init];
    self.decoderController.previewer.watermark = 3;
    self.decoderController.previewer.previewType = VCPreviewerTypeVTLiveH264VideoOnly;
    self.decoderController.parseFilePath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"h264"];
//    self.decoderController.parseFilePath = @"/Users/cmst0us/Desktop/test.h264";
    self.playGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playGestureHandler)];
    self.playGestureRecognizer.numberOfTouchesRequired = 1;
    self.playGestureRecognizer.numberOfTapsRequired = 1;
    
    self.stopGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stopGestureHandler)];
    self.stopGestureRecognizer.numberOfTouchesRequired = 2;
    self.stopGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:self.playGestureRecognizer];
    [self.view addGestureRecognizer:self.stopGestureRecognizer];
    
    
    self.encoderController = [[VCEncoderController alloc] init];
    [self.encoderController runEncoder];
    
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

- (void)playGestureHandler {
    if ([self.decoderController.previewer.currentState isEqualToInteger:VCBaseCodecStateRunning]) {
        [self.decoderController.previewer pause];
    } else if ([self.decoderController.previewer.currentState isEqualToInteger:VCBaseCodecStatePause]) {
        [self.decoderController.previewer resume];
    } else if ([self.decoderController.previewer.currentState isEqualToInteger:VCBaseCodecStateReady]) {
        [self.decoderController startParse];
    } else if ([self.decoderController.previewer.currentState isEqualToInteger:VCBaseCodecStateStop]) {
        [self.decoderController startParse];
    }
}

- (void)stopGestureHandler {
    if ([self.decoderController.previewer.currentState isEqualToInteger:VCBaseCodecStateStop]) {
        [self.decoderController startParse];
    } else if ([self.decoderController.previewer.currentState isEqualToInteger:VCBaseCodecStateReady]) {
        [self.decoderController startParse];
    } else {
        [self.decoderController stopParse];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
