//
//  VCDemoCameraCaptureController.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/10/30.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import "VCDemoCameraCaptureController.h"
@interface VCDemoCameraCaptureController ()<VCBaseEncoderDelegate, AVCaptureVideoDataOutputSampleBufferDelegate> {
    dispatch_queue_t _captureQueue;
    dispatch_queue_t _encodeQueue;
    NSFileHandle *_fileHandle;
}
@property (nonatomic, weak) AVCaptureConnection *connection;
@end

@implementation VCDemoCameraCaptureController
- (instancetype)init {
    self = [super init];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit {
    _currentStatus = VCDemoCameraCaptureStatusReady;
    [self setupEncoder];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)setupEncoder {
    VCH264EncoderConfig *config = [VCH264EncoderConfig defaultConfig];
    self.encoder = [[VCVTH264Encoder alloc] initWithConfig:config];
    self.encoder.delegate = self;
    [self.encoder setup];
}

- (void)startCapture {
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession.sessionPreset = AVCaptureSessionPreset1920x1080;
    
    _captureQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _encodeQueue = dispatch_queue_create("encode_queue", DISPATCH_QUEUE_SERIAL);
    
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
    [self.captureDeviceOutput setAlwaysDiscardsLateVideoFrames:NO];
    
    [self.captureDeviceOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    [self.captureDeviceOutput setSampleBufferDelegate:self queue:_captureQueue];
    if ([self.captureSession canAddOutput:self.captureDeviceOutput]) {
        [self.captureSession addOutput:self.captureDeviceOutput];
    }
    self.connection = [self.captureDeviceOutput connectionWithMediaType:AVMediaTypeVideo];
    [self changeCameraOrientation];
    
    NSString *file = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"abc.h264"];
    [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
    [[NSFileManager defaultManager] createFileAtPath:file contents:nil attributes:nil];
    _fileHandle = [NSFileHandle fileHandleForWritingAtPath:file];
    [self setupEncoder];
    if (![self.encoder run]) {
        NSLog(@"[ENCODER]: Run Error");
        return;
    }
    [self.captureSession startRunning];
    _currentStatus = VCDemoCameraCaptureStatusRunning;
}

- (void)stopCapture {
    [self.captureSession stopRunning];
    [self.encoder invalidate];
    [_fileHandle closeFile];
    _fileHandle = nil;
    _currentStatus = VCDemoCameraCaptureStatusStop;
}

- (NSString *)nextStatusActionTitle {
    if (self.currentStatus == VCDemoCameraCaptureStatusReady
        || self.currentStatus == VCDemoCameraCaptureStatusStop) {
        return NSLocalizedString(@"拍摄", nil);
    } else if (self.currentStatus == VCDemoCameraCaptureStatusRunning) {
        return NSLocalizedString(@"停止拍摄", nil);
    }
    return @"";
}

- (void)changeCameraOrientation {
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (interfaceOrientation == UIInterfaceOrientationPortrait) {
        [self.connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    } else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        [self.connection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
    } else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        [self.connection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
    }
}
- (void)statusBarOrientationChange:(NSNotification *)notification{
    [self changeCameraOrientation];
}

#pragma mark - Capture Delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    //    dispatch_async(_encodeQueue, ^{
    VCYUV420PImage *image = [[VCYUV420PImage alloc] init];
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    [image setPixelBuffer:pixelBuffer];
    [self.encoder encodeWithImage:image];
    //    });
}

#pragma mark - Encoder Delegate
- (void)encoder:(VCBaseEncoder *)encoder didProcessFrame:(VCBaseFrame *)frame {
    NSData *data = [[NSData alloc] initWithBytes:frame.parseData length:frame.parseSize];
    [_fileHandle writeData:data];
}

@end
