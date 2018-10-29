//
//  VCCameraCaptureViewController.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/10/29.
//  Copyright © 2018 eric3u. All rights reserved.
//
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
#import "VCCameraCaptureViewController.h"

@interface VCCameraCaptureViewController () <AVCaptureVideoDataOutputSampleBufferDelegate> {
    dispatch_queue_t _captureQueue;
    dispatch_queue_t _encodeQueue;
    NSFileHandle *_fileHandle;
}
@property (nonatomic, strong) VCVTH264Encoder *encoder;

@property (nonatomic, strong) UILabel *infoLabel;

@property (nonatomic , strong) AVCaptureSession *captureSession; //负责输入和输出设备之间的数据传递
@property (nonatomic , strong) AVCaptureDeviceInput *captureDeviceInput;//负责从AVCaptureDevice获得输入数据
@property (nonatomic , strong) AVCaptureVideoDataOutput *captureDeviceOutput; //
@property (nonatomic , strong) AVCaptureVideoPreviewLayer *previewLayer;
@end

@implementation VCCameraCaptureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
}

- (void)createUI {
    self.infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 200, 100)];
    self.infoLabel.textColor = [UIColor redColor];
    [self.view addSubview:self.infoLabel];
    self.infoLabel.text = @"测试H264硬编码";
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(200, 20, 100, 100)];
    [button setTitle:@"play" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.view addSubview:button];
    [button addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupEncoder {
    VCBaseEncoderConfig *config = [VCH264EncoderConfig defaultConfig];
    
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
    AVCaptureConnection *connection = [self.captureDeviceOutput connectionWithMediaType:AVMediaTypeVideo];
    [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    [self.previewLayer setFrame:self.view.bounds];
    [self.view.layer addSublayer:self.previewLayer];
    
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
}

- (void)stopCapture {
    [self.captureSession stopRunning];
    [self.previewLayer removeFromSuperlayer];
    [self.encoder invalidate];
    [_fileHandle closeFile];
    _fileHandle = nil;
}

#pragma mark - Action
- (void)onClick:(UIButton *)button {
    if (!self.captureSession || !self.captureSession.running) {
        [button setTitle:@"stop" forState:UIControlStateNormal];
        [self startCapture];
        
    }
    else {
        [button setTitle:@"play" forState:UIControlStateNormal];
        [self stopCapture];
    }
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
