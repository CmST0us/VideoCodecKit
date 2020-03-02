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
@property (nonatomic, strong) VCFLVVideoTag *currentAVCTag;

@property (nonatomic, strong) dispatch_queue_t fileQueue;
@property (nonatomic, strong) NSFileHandle *file;

@property (nonatomic, assign) NSUInteger videoFrameCount;
@property (nonatomic, assign) NSUInteger audioFrameCount;
@property (nonatomic, assign) BOOL isOutputAACConfig;
@property (nonatomic, assign) BOOL isOutputAVCConfig;
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
        AVAudioFormat *inputFormat = [VCAudioConverter formatWithCMAudioFormatDescription:self.outputAudioFormat];
        AVAudioFormat *outputFormat = [VCAudioConverter AACFormatWithSampleRate:inputFormat.sampleRate channels:inputFormat.channelCount];
        _audioConverter = [[VCAudioConverter alloc] initWithOutputFormat:outputFormat sourceFormat:inputFormat delegateQueue:dispatch_get_global_queue(0, 0)];
        _audioConverter.delegate = self;
        _audioSpecificConfig = _audioConverter.outputAudioSpecificConfig;
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
    [self requestCaptureSession:^(AVCaptureSession *session) {
        [session setSessionPreset:AVCaptureSessionPreset1920x1080];
    }];
    
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] init];
    _previewLayer.session = self.captureSession;
    
    self.fileQueue = dispatch_queue_create("FILEQUEUE", DISPATCH_QUEUE_SERIAL);
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *filePath = [path stringByAppendingPathComponent:@"test.aac"];
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    self.file = [NSFileHandle fileHandleForWritingAtPath:filePath];
    
    [self.view.layer addSublayer:self.previewLayer];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    self.previewLayer.frame = self.view.bounds;
}

- (void)setupPublisher {
    self.publishQueue = dispatch_queue_create("PublishQueue", DISPATCH_QUEUE_SERIAL);
    
    self.publisher = [[VCRTMPPublisher alloc] initWithURL:[NSURL URLWithString:@"rtmp://192.168.43.17/stream"] publishKey:@"12345"];
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
//            self.audioConverter.bitrate = 160 * 1024;
//            self.audioConverter.audioConverterQuality = kAudioConverterQuality_Max;
        }
    } else if (output == self.videoDataOutput) {
        if (self.canPublish) {
            VCSampleBuffer *videoSampleBuffer = [[VCSampleBuffer alloc] initWithSampleBuffer:sampleBuffer freeWhenDone:NO];
            [self.encoder encodeSampleBuffer:videoSampleBuffer];
        }
    }
}

- (void)converter:(VCAudioConverter *)converter didOutputAudioBuffer:(AVAudioBuffer *)audioBuffer presentationTimeStamp:(CMTime)pts {
    if (!self.isOutputAACConfig) {
        self.isOutputAACConfig = YES;
        VCFLVAudioTag *tag = [VCFLVAudioTag sequenceHeaderTagForAAC];
        tag.payloadData = [self.audioConverter.outputAudioSpecificConfig serialize];
        [self.publisher writeTag:tag];
    }
    VCFLVAudioTag *tag = [VCFLVAudioTag tagForAAC];
    tag.audioType = VCFLVAudioTagAudioTypeStereo;
    AVAudioCompressedBuffer *buf = (AVAudioCompressedBuffer *)audioBuffer;
    [tag setExtendedTimestamp:self.audioFrameCount++ * (1024.0 * 1000.0 / self.audioConverter.outputAudioSpecificConfig.sampleRate)];
    
    NSData *aacData = [[NSData alloc] initWithBytes:buf.data length:buf.byteLength];
    NSData *adts = [self.audioSpecificConfig adtsDataForPacketLength:aacData.length];
    NSMutableData *aac = [[NSMutableData alloc] init];
    [aac appendData:adts];
    [aac appendData:aacData];
    
    dispatch_async(self.fileQueue, ^{
        [self.file writeData:aac];
    });
    
    tag.payloadData = aacData;
    [tag serialize];
    [self.publisher writeTag:tag];
}

- (void)videoEncoder:(id<VCVideoEncoder>)encoder didOutputSampleBuffer:(VCSampleBuffer *)sampleBuffer {
    BOOL isKeyFrame = sampleBuffer.keyFrame;
    uint32_t timestamp = self.videoFrameCount++ * (1000.0 / 30.0);
    if (isKeyFrame) {
        NSData *data = sampleBuffer.dataBufferData;
        VCAVCFormatStream *stream = [[VCAVCFormatStream alloc] initWithData:data startCodeLength:4];
        stream.naluClass = [VCH264NALU class];
        [stream.nalus enumerateObjectsUsingBlock:^(VCH264NALU *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.type == VCH264NALUTypeSliceIDR) {
                VCFLVVideoTag *videoTag = [VCFLVVideoTag tagForAVC];
                videoTag.frameType = VCFLVVideoTagFrameTypeKeyFrame;
                videoTag.AVCPacketType = VCFLVVideoTagAVCPacketTypeNALU;
                [videoTag setExtendedTimestamp:timestamp];
                videoTag.payloadData = [obj warpAVCStartCode];
                [videoTag serialize];
                [self.publisher writeTag:videoTag];
            }
        }];
    } else {
        NSData *data = sampleBuffer.dataBufferData;
        VCAVCFormatStream *stream = [[VCAVCFormatStream alloc] initWithData:data startCodeLength:4];
        stream.naluClass = [VCH264NALU class];
        [stream.nalus enumerateObjectsUsingBlock:^(VCH264NALU *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.type == VCH264NALUTypeSliceData) {
                VCFLVVideoTag *videoTag = [VCFLVVideoTag tagForAVC];
                videoTag.frameType = VCFLVVideoTagFrameTypeInterFrame;
                videoTag.AVCPacketType = VCFLVVideoTagAVCPacketTypeNALU;
                [videoTag setExtendedTimestamp:timestamp];
                videoTag.payloadData = [obj warpAVCStartCode];
                [videoTag serialize];
                [self.publisher writeTag:videoTag];
            }
        }];
    }
}

- (void)videoEncoder:(id<VCVideoEncoder>)encoder didOutputFormatDescription:(CMFormatDescriptionRef)description {
    NSLog(@"description: %@", description);
    if (!self.isOutputAVCConfig) {
        self.isOutputAVCConfig = YES;
        VCAVCConfigurationRecord *recorder = [[VCAVCConfigurationRecord alloc] initWithFormatDescription:description];
        VCFLVVideoTag *avcTag = [VCFLVVideoTag sequenceHeaderTagForAVC];
        avcTag.payloadData = recorder.data;
        [avcTag setExtendedTimestamp:0];
        [avcTag serialize];
        [self.publisher writeTag:avcTag];
    }
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
    self.audioFrameCount = 0;
    self.videoFrameCount = 0;
    self.isOutputAACConfig = NO;
    self.isOutputAVCConfig = NO;
    [self.publisher start];
}
@end

