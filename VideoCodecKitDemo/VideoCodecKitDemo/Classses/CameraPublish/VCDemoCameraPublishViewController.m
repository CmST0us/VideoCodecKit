//
//  VCDemoCameraPublishViewController.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2020/2/16.
//  Copyright © 2020 eric3u. All rights reserved.
//

@import VideoCodecKit;
#import <AVFoundation/AVFoundation.h>
#import <VideoToolbox/VideoToolbox.h>
#import "VCDemoCameraPublishViewController.h"

@interface VCDemoCameraPublishViewController () <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, VCAudioConverterDelegate, VCRTMPPublisherDelegate, VCVideoEncoderDelegate>
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDevice *cameraDevice;
@property (nonatomic, strong) AVCaptureDevice *audioDevice;
@property (nonatomic, strong) AVCaptureDeviceInput *cameraInput;
@property (nonatomic, strong) AVCaptureDeviceInput *audioInput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) AVCaptureAudioDataOutput *audioDataOutput;

@property (nonatomic, strong) dispatch_queue_t sessionSettingQueue;
@property (nonatomic, strong) dispatch_queue_t sampleBufferOutputQueue;

@property (nonatomic, strong) VCAudioConverter *audioConverter;
@property (nonatomic, assign) CMFormatDescriptionRef outputAudioFormat;
@property (nonatomic, strong) VCAudioSpecificConfig *audioSpecificConfig;

@property (nonatomic, strong) VCRTMPPublisher *publisher;
@property (nonatomic, strong) dispatch_queue_t publishQueue;
@property (nonatomic, assign) BOOL canPublish;

@property (nonatomic, strong) VCH264HardwareEncoder *encoder;

@end

@implementation VCDemoCameraPublishViewController

- (void)dealloc {
    if (_outputAudioFormat) {
        CFRelease(_outputAudioFormat);
        _outputAudioFormat = NULL;
    }
}

- (void)setOutputAudioFormat:(CMFormatDescriptionRef)outputAudioFormat {
    if (CMFormatDescriptionEqual(outputAudioFormat, _outputAudioFormat)) {
        return;
    }
    if (_outputAudioFormat) {
        CFRelease(_outputAudioFormat);
        _outputAudioFormat = NULL;
    }
    _outputAudioFormat = CFRetain(outputAudioFormat);
    _audioConverter = nil;
}

- (VCAudioConverter *)audioConverter {
    if (_audioConverter == nil) {
        AVAudioFormat *inputFormat = [[AVAudioFormat alloc] initWithCMAudioFormatDescription:self.outputAudioFormat];
        AVAudioFormat *outputFormat = [AVAudioFormat AACFormatWithSampleRate:inputFormat.sampleRate channels:inputFormat.channelCount];
        _audioConverter = [[VCAudioConverter alloc] initWithOutputFormat:outputFormat sourceFormat:inputFormat delegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
        _audioConverter.delegate = self;
        _audioSpecificConfig = outputFormat.audioSpecificConfig;
    }
    return _audioConverter;
}

- (VCH264HardwareEncoder *)encoder {
    if (_encoder == nil) {
        _encoder = [[VCH264HardwareEncoder alloc] init];
        _encoder.width = 1920;
        _encoder.height = 1080;
        _encoder.delegate = self;
    }
    return _encoder;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        
    }];
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
     
    }];
    
    [self setupPublisher];
    [self setupQueue];
    [self setupDevice];
    [self setupSession];
    
    [self requestCaptureSession:^(AVCaptureSession *session) {
        [session startRunning];
    }];
    
    __weak typeof(self) weakSelf = self;
    [self requestCaptureSession:^(AVCaptureSession *session) {
        [session setSessionPreset:AVCaptureSessionPreset1920x1080];
        
        [weakSelf.cameraDevice lockForConfiguration:nil];
        for (AVCaptureDeviceFormat *format in weakSelf.cameraDevice.formats) {
            for (AVFrameRateRange *range in format.videoSupportedFrameRateRanges) {
                if (0 == CMTimeCompare(range.minFrameDuration, CMTimeMake(1, 60))) {
                    [weakSelf.cameraDevice setActiveFormat:format];
                    [weakSelf.cameraDevice setActiveVideoMaxFrameDuration:CMTimeMake(1, 60)];
                    [weakSelf.cameraDevice setActiveVideoMinFrameDuration:CMTimeMake(1, 60)];
                    break;
                }
            }
        }
        [self.cameraDevice unlockForConfiguration];
    }];
    
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] init];
    _previewLayer.session = self.captureSession;
    
    [self.view.layer addSublayer:self.previewLayer];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    self.previewLayer.frame = self.view.bounds;
}

- (void)setupPublisher {
    self.publishQueue = dispatch_queue_create("PublishQueue", DISPATCH_QUEUE_SERIAL);
    
    self.publisher = [[VCRTMPPublisher alloc] initWithURL:[NSURL URLWithString:@"rtmp://192.168.43.17/stream/"] publishKey:@"12345"];
    self.publisher.delegate = self;
    self.publisher.connectionParameter = @{
        @"flashVer": @"FMLE/3.0 (compatible; FMSc/1.0)".asString,
        @"swfUrl": NSNull.asNull,
        @"fpad": @(NO).asBool,
        @"audioCodecs": @(0x0400).asNumber,
        @"videoCodecs": @(0x0080).asNumber,
        @"objectEncodeing": @(0).asNumber,
    };
    self.publisher.streamMetaData = @{
        @"duration": @(0).asNumber,
        @"fileSize": @(0).asNumber,
        @"width": @(1920).asNumber,
        @"height": @(1080).asNumber,
        @"videocodecid": @"avc1".asString,
        @"videodatarate": @(2500).asNumber,
        @"framerate": @(30).asNumber,
        @"audiocodecid": @"mp4a".asString,
        @"audiodatarate": @(160).asNumber,
        @"audiosamplerate": @"44100".asString,
        @"audiosamplesize": @(16).asNumber,
        @"audiochannels": @(1).asNumber,
        @"stereo": @(YES).asBool,
        @"2.1": @(NO).asBool,
        @"3.1": @(NO).asBool,
        @"4.0": @(NO).asBool,
        @"4.1": @(NO).asBool,
        @"5.1": @(NO).asBool,
        @"7.1": @(NO).asBool,
        @"encoder": @"iOSVT::VideoCodecKit".asString,
    };
}

- (void)setupQueue {
    self.sessionSettingQueue = dispatch_queue_create("CameraKit::SessionSettingQueue", DISPATCH_QUEUE_SERIAL);
    self.sampleBufferOutputQueue = dispatch_queue_create("CameraKit::SampleBufferOutputQueue", DISPATCH_QUEUE_SERIAL);
}


- (void)setupDevice {
    self.cameraDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    self.cameraInput = [AVCaptureDeviceInput deviceInputWithDevice:self.cameraDevice error:nil];
    self.audioInput = [AVCaptureDeviceInput deviceInputWithDevice:self.audioDevice error:nil];
    
    self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [self.videoDataOutput setSampleBufferDelegate:self queue:self.sampleBufferOutputQueue];
    self.audioDataOutput = [[AVCaptureAudioDataOutput alloc] init];
    [self.audioDataOutput setSampleBufferDelegate:self queue:self.sampleBufferOutputQueue];
}

- (void)setupSession {
    self.captureSession = [[AVCaptureSession alloc] init];
    
    if ([self.captureSession canAddInput:self.cameraInput]) {
        [self.captureSession addInput:self.cameraInput];
    }
    
    if ([self.captureSession canAddInput:self.audioInput]) {
        [self.captureSession addInput:self.audioInput];
    }
    
    if ([self.captureSession canAddOutput:self.videoDataOutput]) {
        [self.captureSession addOutput:self.videoDataOutput];
    }
    
    if ([self.captureSession canAddOutput:self.audioDataOutput]) {
        [self.captureSession addOutput:self.audioDataOutput];
    }
}

- (void)requestCaptureSession:(void(^)(AVCaptureSession *session))block {
    dispatch_async(self.sessionSettingQueue, ^{
        if (block) {
            if (self.captureSession.isRunning) {
                [self.captureSession beginConfiguration];
            }
            block(self.captureSession);
            if (self.captureSession.isRunning) {
                [self.captureSession commitConfiguration];
            }
        }
    });
}

#pragma mark - Delegate
- (void)captureOutput:(AVCaptureOutput *)output didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    NSLog(@"drop frame");
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (output == self.audioDataOutput) {
        if (self.canPublish) {
            self.outputAudioFormat = CMSampleBufferGetFormatDescription(sampleBuffer);
            VCSampleBuffer *audioSampleBuffer = [[VCSampleBuffer alloc] initWithSampleBuffer:sampleBuffer freeWhenDone:NO];
            [self.audioConverter convertSampleBuffer:audioSampleBuffer];
        }
    } else if (output == self.videoDataOutput) {
        if (self.canPublish) {
            VCSampleBuffer *videoSampleBuffer = [[VCSampleBuffer alloc] initWithSampleBuffer:sampleBuffer freeWhenDone:NO];
            [self.encoder encodeSampleBuffer:videoSampleBuffer];
        }
    }
}

- (void)converter:(VCAudioConverter *)converter didOutputSampleBuffer:(VCSampleBuffer *)sampleBuffer {
    [self.publisher publishSampleBuffer:sampleBuffer];
}

- (void)converter:(nonnull VCAudioConverter *)converter didOutputFormatDescriptor:(nonnull CMFormatDescriptionRef)formatDescription {
    [self.publisher publishFormatDescription:formatDescription];
}


- (void)videoEncoder:(id<VCVideoEncoder>)encoder didOutputSampleBuffer:(VCSampleBuffer *)sampleBuffer {
    [self.publisher publishSampleBuffer:sampleBuffer];
}

- (void)videoEncoder:(id<VCVideoEncoder>)encoder didOutputFormatDescription:(CMFormatDescriptionRef)description {
    [self.publisher publishFormatDescription:description];
}

- (void)publisher:(VCRTMPPublisher *)publisher didChangeState:(VCRTMPPublisherState)state error:(NSError *)error {
    if (state == VCRTMPPublisherStateReadyToPublish) {
        NSLog(@"Publisher Ready");
        self.canPublish = YES;
    } else if (state == VCRTMPPublisherStateError) {
        NSLog(@"Publisher Error %@", error);
    } else if (state == VCRTMPPublisherStateEnd) {
        NSLog(@"Publisher End");
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.publisher start];
}
@end

