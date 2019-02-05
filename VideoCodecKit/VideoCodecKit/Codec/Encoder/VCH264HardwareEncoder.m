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

#define kVCH264HardwareEncoderDefaultWidth 480
#define kVCH264HardwareEncoderDefaultHeight 640

@interface VCH264HardwareEncoder ()
@property (nonatomic, assign) VTCompressionSessionRef session;
@property (nonatomic, assign) CMFormatDescriptionRef formatDescription;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, assign) BOOL shouldInvalidateSession;
@end

@implementation VCH264HardwareEncoder
void compressionOutputCallback(void * CM_NULLABLE outputCallbackRefCon,
                               void * CM_NULLABLE sourceFrameRefCon,
                               OSStatus status,
                               VTEncodeInfoFlags infoFlags,
                               CM_NULLABLE CMSampleBufferRef sampleBuffer) {
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
        self.properties = [VCH264HardwareEncoder defaultProperties];
        self.imageBufferAttributes = [VCH264HardwareEncoder defaultImageBufferAttributes];
        self.width = kVCH264HardwareEncoderDefaultWidth;
        self.height = kVCH264HardwareEncoderDefaultHeight;
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

- (void)setWidth:(NSInteger)width {
    if (_width == width) {
        return;
    }
    _width = width;
    _shouldInvalidateSession = YES;
}

- (void)setHeight:(NSInteger)height {
    if (_height == height) {
        return;
    }
    _height = height;
    _shouldInvalidateSession = YES;
}

- (void)setBitrate:(NSInteger)bitrate {
    if (_bitrate == bitrate) {
        return;
    }
    _bitrate = bitrate;
    [self setSessionPropertyWithKey:kVTCompressionPropertyKey_AverageBitRate value:(__bridge CFNumberRef)[NSNumber numberWithInteger:bitrate]];
}

- (void)setFrameRate:(double)frameRate {
    if (_frameRate == frameRate) return;
    _frameRate = frameRate;
    [self setSessionPropertyWithKey:kVTCompressionPropertyKey_ExpectedFrameRate value:(__bridge CFNumberRef)[NSNumber numberWithDouble:_frameRate]];
}

- (void)setProfileLevel:(NSString *)profileLevel {
    if ([_profileLevel compare:profileLevel] == NSOrderedSame) return;
    _profileLevel = [profileLevel copy];
    _shouldInvalidateSession = YES;
}

- (void)setMaxKeyFrameIntervalDuration:(double)maxKeyFrameIntervalDuration {
    if (_maxKeyFrameIntervalDuration == maxKeyFrameIntervalDuration) return;
    _maxKeyFrameIntervalDuration = maxKeyFrameIntervalDuration;
    [self setSessionPropertyWithKey:kVTCompressionPropertyKey_MaxKeyFrameIntervalDuration value:(__bridge CFNumberRef)[NSNumber numberWithDouble:maxKeyFrameIntervalDuration]];
}

- (void)setMaxKeyFrameInterval:(NSInteger)maxKeyFrameInterval {
    if (_maxKeyFrameInterval == maxKeyFrameInterval) return;
    _maxKeyFrameInterval = maxKeyFrameInterval;
    [self setSessionPropertyWithKey:kVTCompressionPropertyKey_MaxKeyFrameInterval value:(__bridge CFNumberRef)[NSNumber numberWithInteger:maxKeyFrameInterval]];
}

- (void)setRealTime:(BOOL)realTime {
    if (_realTime == realTime) return;
    _realTime = realTime;
    _shouldInvalidateSession = YES;
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
    BOOL isBaseline = [self.profileLevel rangeOfString:@"Baseline"].length != 0;
    return @{
             (id)kVTCompressionPropertyKey_RealTime: [NSNumber numberWithBool:self.realTime],
             (id)kVTCompressionPropertyKey_ProfileLevel: self.profileLevel,
             (id)kVTCompressionPropertyKey_AverageBitRate: [NSNumber numberWithInteger:self.bitrate],
             (id)kVTCompressionPropertyKey_ExpectedFrameRate: [NSNumber numberWithDouble:self.frameRate],
             (id)kVTCompressionPropertyKey_MaxKeyFrameInterval: [NSNumber numberWithInteger:self.maxKeyFrameInterval],
             (id)kVTCompressionPropertyKey_MaxKeyFrameIntervalDuration: [NSNumber numberWithDouble:self.maxKeyFrameIntervalDuration],
             (id)kVTCompressionPropertyKey_AllowFrameReordering: [NSNumber numberWithBool:!isBaseline],
             };
}

- (void)setAttributes:(NSDictionary *)attributes {
    NSNumber *realTime = attributes[(id)kVTCompressionPropertyKey_RealTime];
    if (realTime) {
        self.realTime = realTime.boolValue;
    }
    
    NSString *profile = attributes[(id)kVTCompressionPropertyKey_ProfileLevel];
    if (profile) {
        self.profileLevel = profile;
    }
    
    NSNumber *bitRate = attributes[(id)kVTCompressionPropertyKey_AverageBitRate];
    if (bitRate) {
        self.bitrate = bitRate.integerValue;
    }
    
    NSNumber *frameRate = attributes[(id)kVTCompressionPropertyKey_ExpectedFrameRate];
    if (frameRate) {
        self.frameRate = frameRate.doubleValue;
    }
    
    NSNumber *maxFrameInterval = attributes[(id)kVTCompressionPropertyKey_MaxKeyFrameInterval];
    if (maxFrameInterval) {
        self.maxKeyFrameInterval = maxFrameInterval.integerValue;
    }
    
    NSNumber *maxFrameIntervalDuration = attributes[(id)kVTCompressionPropertyKey_MaxKeyFrameIntervalDuration];
    if (maxFrameIntervalDuration) {
        self.maxKeyFrameIntervalDuration = maxFrameIntervalDuration.doubleValue;
    }
}

+ (NSArray *)supportProperties {
    return @[
             @"width",
             @"height",
             @"bitrate",
             @"frameRate",
             @"profileLevel",
             @"maxKeyFrameInterval",
             @"maxKeyFrameIntervalDuration",
             @"realTime"
             ];
}

+ (NSDictionary *)defaultProperties {
    return @{
             (id)kVTCompressionPropertyKey_RealTime: [NSNumber numberWithBool:YES],
             (id)kVTCompressionPropertyKey_ProfileLevel: (id)kVTProfileLevel_H264_Baseline_AutoLevel,
             (id)kVTCompressionPropertyKey_AverageBitRate: [NSNumber numberWithInteger:160 * 1024],
             (id)kVTCompressionPropertyKey_ExpectedFrameRate: [NSNumber numberWithDouble:30],
             (id)kVTCompressionPropertyKey_MaxKeyFrameInterval: [NSNumber numberWithInteger:0],
             (id)kVTCompressionPropertyKey_MaxKeyFrameIntervalDuration: [NSNumber numberWithDouble:1],
             (id)kVTCompressionPropertyKey_AllowFrameReordering: [NSNumber numberWithBool:NO],
             };
}

+ (NSDictionary *)defaultImageBufferAttributes {
    return @{
             (id)kCVPixelBufferIOSurfacePropertiesKey: @{},
#if TARGET_OS_IOS
             (id)kCVPixelBufferOpenGLESCompatibilityKey: [NSNumber numberWithBool:YES],
#else
             (id)kCVPixelBufferOpenGLCompatibilityKey: [NSNumber numberWithBool:YES];
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
    
    OSStatus ret = VTCompressionSessionCreate(kCFAllocatorDefault, (int32_t)self.width, (int32_t)self.height, kCMVideoCodecType_H264, nil, (__bridge CFDictionaryRef)self.imageBufferAttributes, nil, compressionOutputCallback, (__bridge void*)self, &_session);
    if (ret != noErr) return nil;
    ret = VTSessionSetProperties(_session, (__bridge CFDictionaryRef)self.properties);
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

- (OSStatus)encodeSampleBuffer:(VCSampleBuffer *)sampleBuffer {
    if (self.session == nil) return -1;
    VTEncodeInfoFlags flags = 0;
    return VTCompressionSessionEncodeFrame(self.session, sampleBuffer.imageBuffer, sampleBuffer.presentationTimeStamp, sampleBuffer.duration, nil, (__bridge void *)self, &flags);
    
}

@end
