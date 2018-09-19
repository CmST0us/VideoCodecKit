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
#import "LYOpenGLView.h"
#import "VCYUV420PImage.h"

@interface ViewController ()
@property (nonatomic, strong) VCDecodeController *decoderController;
//@property (nonatomic, strong) LYOpenGLView *glView;
@property (nonatomic, assign) NSInteger decodeFrameCount;

@property (nonatomic, strong) AVSampleBufferDisplayLayer *displayLayer;
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
    self.displayLayer = [AVSampleBufferDisplayLayer layer];
    self.displayLayer.frame = self.view.bounds;
    self.displayLayer.position = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    self.displayLayer.opaque = YES;
    self.displayLayer.videoGravity = AVLayerVideoGravityResize;
    [self.view.layer addSublayer:self.displayLayer];
}

- (void)bindData {
    weakSelf(target);

    [self.displayLayer addKVSigObserver:self forKeyPath:KVSKeyPath([self displayLayer].status) handle:^(NSObject *oldValue, NSObject *newValue) {
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
    if (![[image classStringForImageType] isEqualToString:NSStringFromClass([VCYUV420PImage class])]) return;
    VCYUV420PImage *renderImage = (VCYUV420PImage *)image;
    if (renderImage == nil) return;
    
    CVPixelBufferRef pixelBuffer = [renderImage pixelBuffer];
    if (pixelBuffer == NULL) return;
    
    CMTime durTime;
    durTime.value = 1;
    durTime.timescale = 30;
    CMSampleTimingInfo timing = {durTime, kCMTimeInvalid, kCMTimeInvalid};
    
    CMVideoFormatDescriptionRef videoInfo = NULL;
    OSStatus ret = CMVideoFormatDescriptionCreateForImageBuffer(NULL, pixelBuffer, &videoInfo);
    NSAssert(ret == 0, @"desc create err");
    CMSampleBufferRef sampleBuffer = NULL;
    ret = CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer, true, NULL, NULL, videoInfo, &timing, &sampleBuffer);
    NSAssert(ret == 0, @"sample buffer create err");
    
    
    CFArrayRef attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, YES);
    CFMutableDictionaryRef dict = (CFMutableDictionaryRef)CFArrayGetValueAtIndex(attachments, 0);
    CFDictionarySetValue(dict, kCMSampleAttachmentKey_DisplayImmediately, kCFBooleanTrue);
    
    if ([self.displayLayer isReadyForMoreMediaData]) {
        [self.displayLayer enqueueSampleBuffer:sampleBuffer];
    }
    
    //
    //    NSString *filePath = [[NSString alloc] initWithFormat:@"/Users/cmst0us/Desktop/output/%lu.yuv", (unsigned long)frame.frameIndex];
    //    [[frame.image nv12PlaneData] writeToFile:filePath atomically:YES];
    CFRelease(videoInfo);
    CFRelease(sampleBuffer);
    CVPixelBufferRelease(pixelBuffer);
}

@end
