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

#import "ViewController.h"
#import "VCDecodeController.h"
#import "VCYUV420PImage.h"
#import "VCSampleBufferRender.h"

@interface ViewController ()
@property (nonatomic, strong) VCDecodeController *decoderController;
@property (nonatomic, assign) NSInteger decodeFrameCount;
@property (nonatomic, strong) VCSampleBufferRender *render;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDisplayLayer];
    
    self.decoderController = [[VCDecodeController alloc] init];
    self.decoderController.parseFilePath = @"/Users/cmst0us/Desktop/swift.h264";
    self.decoderController.decoder.delegate = self;
    
    [self bindData];
}

- (void)setupDisplayLayer {
    self.render = [[VCSampleBufferRender alloc] initWithSuperLayer:self.view.layer];
    [self.render attachToSuperLayer];
    self.render.renderLayer.frame = self.view.layer.bounds;
}

- (void)bindData {
    weakSelf(target);

    [self.render addKVSigObserver:self forKeyPath:KVSKeyPath([self render].renderLayer.status) handle:^(NSObject *oldValue, NSObject *newValue) {
        NSNumber *status = (NSNumber *)newValue;
        if ([status isEqualToNumber:@(AVQueuedSampleBufferRenderingStatusUnknown)]) {
            NSLog(@"faild");
        }
        if ([status isEqualToNumber:@(AVQueuedSampleBufferRenderingStatusFailed)]) {
            NSLog(@"unknow");
        }
        if ([status isEqualToNumber:@(AVQueuedSampleBufferRenderingStatusRendering)]) {
            NSLog(@"render");
        }
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if ([self.decoderController.decoder.currentState isEqualToNumber:@(VCBaseDecoderStateRunning)]) {
        [self.decoderController stopParse];
    } else if ([self.decoderController.decoder.currentState isEqualToNumber:@(VCBaseDecoderStateStop)]) {
        [self.decoderController startParse];
    } else if ([self.decoderController.decoder.currentState isEqualToNumber:@(VCBaseDecoderStateInit)]) {
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

- (void)decoder:(VCBaseDecoder *)decoder didProcessFrame:(id<VCImageTypeProtocol>)image {
    [self.render renderImage:image];
}

@end
