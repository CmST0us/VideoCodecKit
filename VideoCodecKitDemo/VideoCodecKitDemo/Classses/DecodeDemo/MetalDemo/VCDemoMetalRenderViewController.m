//
//  VCDemoMetalRenderViewController.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/10/31.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import "VCDemoMetalRenderViewController.h"
#import <VideoCodecKit/VideoCodecKit.h>
#if (TARGET_IPHONE_SIMULATOR)
#else

@interface VCDemoMetalRenderViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate> {
    dispatch_queue_t _captureQueue;
}
@property (nonatomic, strong) VCMetalRender *render;
@end

@implementation VCDemoMetalRenderViewController

- (void)customInit {
    [super customInit];
    
    self.render = [[VCMetalRender alloc] init];
    [self.view addSubview:self.render.mtkView];
    
    [self createConstraint];
}

- (void)createConstraint {
    [self.render.mtkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.backButton.mas_bottom).offset(8);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self startCapture];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self stopCapture];
}

- (void)startCapture {
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession.sessionPreset = AVCaptureSessionPreset1920x1080;
    
    _captureQueue = dispatch_queue_create("metal_camera_capture_queue", DISPATCH_QUEUE_SERIAL);
    AVCaptureDevice *inputCamera = nil;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == AVCaptureDevicePositionBack)
        {
            inputCamera = device;
        }
    }
    
    self.captureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:inputCamera error:nil];
    
    if ([self.captureSession canAddInput:self.captureDeviceInput]) {
        [self.captureSession addInput:self.captureDeviceInput];
    }
    
    self.captureDeviceOutput = [[AVCaptureVideoDataOutput alloc] init];
    [self.captureDeviceOutput setAlwaysDiscardsLateVideoFrames:YES];
    [self.captureDeviceOutput setVideoSettings:@{
                                                 (id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
                                                 }];
    [self.captureDeviceOutput setSampleBufferDelegate:self queue:_captureQueue];
    if ([self.captureSession canAddOutput:self.captureDeviceOutput]) {
        [self.captureSession addOutput:self.captureDeviceOutput];
    }
    [self.captureSession startRunning];
}

- (void)stopCapture {
    [self.captureSession stopRunning];
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    VCYUV420PImage *image = [[VCYUV420PImage alloc] initWithPixelBuffer:pixelBuffer];
    // 注意这个会持有pixelBuffer,导致sampleBuffer 重用出问题
    [self.render renderImage:image];
}
@end
#endif
