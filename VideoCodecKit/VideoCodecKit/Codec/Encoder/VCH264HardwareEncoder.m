//
//  VCH264HardwareEncoder.m
//  VideoCodecKit
//
//  Created by CmST0us on 2019/1/19.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <VideoToolbox/VideoToolbox.h>

#import "VCSampleBuffer.h"
#import "VCH264HardwareEncoder.h"

#define kVCH264HardwareEncoderDefaultWidth 640
#define kVCH264HardwareEncoderDefaultHeight 480

@implementation VCH264HardwareEncoderParameter
- (id)copyWithZone:(nullable NSZone *)zone {
    VCH264HardwareEncoderParameter *parameter = [[self class] allocWithZone:zone];
    parameter.width = self.width;
    parameter.height = self.height;
    parameter.bitrate = self.bitrate;
    parameter.frameRate = self.frameRate;
    parameter.profileLevel = self.profileLevel;
    parameter.maxKeyFrameInterval = self.maxKeyFrameInterval;
    parameter.maxKeyFrameIntervalDuration = self.maxKeyFrameIntervalDuration;
    parameter.realTime = self.realTime;
    parameter.allowFrameReordering = self.allowFrameReordering;
    return parameter;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        _realTime = @(YES);
        _profileLevel = (id)kVTProfileLevel_H264_Main_AutoLevel;
        _bitrate = @(160 * 1024);
        _frameRate = @(60);
        _maxKeyFrameInterval = @(0);
        _maxKeyFrameIntervalDuration = @(1);
        _allowFrameReordering = @(NO);
        _width = @(1280);
        _height = @(720);
    }
    return self;
}
@end

@interface VCH264HardwareEncoder ()
@property (nonatomic, assign) VTCompressionSessionRef session;
@property (nonatomic, assign) CMFormatDescriptionRef formatDescription;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, assign) BOOL shouldInvalidateSession;

@property (nonatomic, strong) VCH264HardwareEncoderParameter *parameter;
@property (nonatomic, strong) VCH264HardwareEncoderParameter *currentConfigurationParameter;
@end

@implementation VCH264HardwareEncoder
void compressionOutputCallback(void * CM_NULLABLE outputCallbackRefCon,
                               void * CM_NULLABLE sourceFrameRefCon,
                               OSStatus status,
                               VTEncodeInfoFlags infoFlags,
                               CM_NULLABLE CMSampleBufferRef sampleBuffer) {
    if (status != noErr) {
        return;
    }
    VCH264HardwareEncoder *encoder = (__bridge VCH264HardwareEncoder *)outputCallbackRefCon;
    [encoder compressionDidOutputWithSourceFrameRefCon:sourceFrameRefCon status:status infoFlags:infoFlags sampleBuffer:sampleBuffer];
}

- (void)compressionDidOutputWithSourceFrameRefCon:(void *)sourceFrameRefCon
                                           status:(OSStatus)status
                                        infoFlags:(VTEncodeInfoFlags)infoFlags
                                     sampleBuffer:(CMSampleBufferRef)sampleBuffer {
    if (status != noErr) return;
    VCSampleBuffer *outputSampleBuffer = [[VCSampleBuffer alloc] initWithSampleBuffer:(CMSampleBufferRef)CFRetain(sampleBuffer)];
    self.formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(videoEncoder:didOutputSampleBuffer:)]) {
        [self.delegate videoEncoder:self didOutputSampleBuffer:outputSampleBuffer];
    }
}

- (void)dealloc {
    if (_session != nil) {
        VTCompressionSessionInvalidate(_session);
        CFRelease(_session);
        _session = nil;
    }
    if (_formatDescription != nil) {
        CFRelease(_formatDescription);
        _formatDescription = nil;
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _queue = dispatch_queue_create("com.VideoCodecKit.VCH264HardwareEncoder.queue", DISPATCH_QUEUE_SERIAL);
        _parameter = [[VCH264HardwareEncoderParameter alloc] init]; 
        _imageBufferAttributes = [VCH264HardwareEncoder defaultImageBufferAttributes];
    }
    return self;
}

- (void)setSessionPropertyWithKey:(CFStringRef)key
                            value:(CFTypeRef)value {
    dispatch_async(self.queue, ^{
        if (self.session == nil) return;
        VTSessionSetProperty(self.session, key, value);
    });
}

- (void)setFormatDescription:(CMFormatDescriptionRef)formatDescription {
    if (CMFormatDescriptionEqual(_formatDescription, formatDescription)) return;
    if (_formatDescription != nil) {
        CFRelease(_formatDescription);
    }
    _formatDescription = CFRetain(formatDescription);
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(videoEncoder:didOutputFormatDescription:)]) {
        [self.delegate videoEncoder:self didOutputFormatDescription:_formatDescription];
    }
}

- (NSDictionary *)attributes {
    return @{
             (__bridge NSString *)kVTCompressionPropertyKey_RealTime: self.parameter.realTime,
             (__bridge NSString *)kVTCompressionPropertyKey_ProfileLevel: self.parameter.profileLevel,
             (__bridge NSString *)kVTCompressionPropertyKey_AverageBitRate: self.parameter.bitrate,
             (__bridge NSString *)kVTCompressionPropertyKey_ExpectedFrameRate: self.parameter.frameRate,
             (__bridge NSString *)kVTCompressionPropertyKey_MaxKeyFrameInterval: self.parameter.maxKeyFrameInterval,
             (__bridge NSString *)kVTCompressionPropertyKey_MaxKeyFrameIntervalDuration: self.parameter.maxKeyFrameIntervalDuration,
             (__bridge NSString *)kVTCompressionPropertyKey_AllowFrameReordering: self.parameter.allowFrameReordering,
             };
}

+ (NSDictionary *)defaultImageBufferAttributes {
    return @{
             (id)kCVPixelBufferIOSurfacePropertiesKey: @{},
#if TARGET_OS_IOS
             (id)kCVPixelBufferOpenGLESCompatibilityKey: [NSNumber numberWithBool:YES],
#else
             (id)kCVPixelBufferOpenGLCompatibilityKey: [NSNumber numberWithBool:YES],
#endif
             };
}

- (VTCompressionSessionRef)session {
    if (_session != nil && _shouldInvalidateSession == NO) {
        return _session;
    }
    if (_session != nil) {
        VTCompressionSessionInvalidate(_session);
        CFRelease(_session);
        _session = nil;
    }
    
    OSStatus ret = VTCompressionSessionCreate(kCFAllocatorDefault,
                                              (int32_t)self.parameter.width.integerValue,
                                              (int32_t)self.parameter.height.integerValue,
                                              kCMVideoCodecType_H264,
                                              NULL,
                                              (__bridge CFDictionaryRef)self.imageBufferAttributes,
                                              NULL,
                                              compressionOutputCallback,
                                              (__bridge void*)self,
                                              &_session);
    if (ret != noErr) return nil;
    NSDictionary *attributes = [self attributes];
    ret = VTSessionSetProperties(_session,
                                 (__bridge CFDictionaryRef)attributes);
    if (ret != noErr) {
        VTCompressionSessionInvalidate(_session);
        CFRelease(_session);
        _session = nil;
        return nil;
    }
    ret = VTCompressionSessionPrepareToEncodeFrames(_session);
    if (ret != noErr) {
        VTCompressionSessionInvalidate(_session);
        CFRelease(_session);
        _session = nil;
        return nil;
    }
    _shouldInvalidateSession = NO;
    return _session;
}

- (VCH264HardwareEncoderParameter *)beginConfiguration {
    self.currentConfigurationParameter = [self.parameter copy];
    return self.currentConfigurationParameter;
}

- (void)commitConfiguration {
    self.parameter = [self.currentConfigurationParameter copy];
    self.currentConfigurationParameter = nil;
    
    self.shouldInvalidateSession = YES;
}

- (OSStatus)encodeSampleBuffer:(VCSampleBuffer *)sampleBuffer {
    if (self.session == nil) return -1;
    VTEncodeInfoFlags flags = 0;
    return VTCompressionSessionEncodeFrame(self.session, sampleBuffer.imageBuffer, sampleBuffer.presentationTimeStamp, sampleBuffer.duration, nil, (__bridge void *)self, &flags);
    
}

@end
