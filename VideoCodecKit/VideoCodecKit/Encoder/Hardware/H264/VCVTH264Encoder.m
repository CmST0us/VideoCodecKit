//
//  VCVTH264Encoder.m
//  VideoCodecKit
//
//  Created by CmST0us on 2018/10/23.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import <VideoToolbox/VideoToolbox.h>
#import "VCBaseEncoderConfig.h"
#import "VCVTH264Encoder.h"

@interface VCVTH264Encoder () {
    VTCompressionSessionRef _compressionSession;
}

@end

@implementation VCVTH264Encoder

void outputCallback(void * CM_NULLABLE outputCallbackRefCon,
                                 void * CM_NULLABLE sourceFrameRefCon,
                                 OSStatus status,
                                 VTEncodeInfoFlags infoFlags,
                                 CM_NULLABLE CMSampleBufferRef sampleBuffer) {
    
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _compressionSession = nil;
    }
    return self;
}

- (instancetype)initWithConfig:(VCBaseEncoderConfig *)config {
    self = [super initWithConfig:config];
    if (self) {
        
    }
    return self;
}

- (BOOL)setup {
    if (![super setup]) {
        [self rollbackStateTransition];
        return NO;
    }
    
    VTCompressionSessionRef compressionSession;
    OSStatus ret = VTCompressionSessionCreate(kCFAllocatorDefault,
                               (int)self.config.width,
                               (int)self.config.height,
                               self.config.codecType,
                               NULL,
                               NULL,
                               NULL,
                               outputCallback,
                              (__bridge void * _Nullable)(self),
                               &compressionSession);
    if (ret != 0) {
#if DEBUG
        NSLog(@"[ENCODER][VT]: could not create compression session");
#endif
        [self rollbackStateTransition];
        return NO;
    }
    _compressionSession = compressionSession;
    if (self.config.isRealTime) {
        VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_RealTime, kCFBooleanTrue);
    }
    
    switch (self.config.quality) {
        case VCBaseEncoderQualityNormal:
            VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_ProfileLevel, kVTProfileLevel_H264_Main_AutoLevel);
            break;
        case VCBaseEncoderQualityFast:
            VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_ProfileLevel, kVTProfileLevel_H264_Baseline_AutoLevel);
            break;
        case VCBaseEncoderQualityGood:
            VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_ProfileLevel, kVTProfileLevel_H264_High_AutoLevel);
            break;
        case VCBaseEncoderQualitySpliendid:
            VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_ProfileLevel, kVTProfileLevel_H264_High_5_1);
            break;
        default:
            break;
    }
    
    NSInteger gopSize = self.config.gopSize;
    CFNumberRef gopSizeRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &gopSize);
    VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_MaxKeyFrameInterval, gopSizeRef);
    
    NSInteger fps = self.config.fps;
    CFNumberRef fpsRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &fps);
    VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_ExpectedFrameRate, fpsRef);
    
//    int bitRate = width * height * 3 * 4 * 8;
    NSInteger bitrate = self.config.bitrate;
    CFNumberRef bitRateRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &bitrate);
    VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_AverageBitRate, bitRateRef);
    
    //设置码率，上限，单位是bps
//    int bitRateLimit = width * height * 3 * 4;
//    CFNumberRef bitRateLimitRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &bitRateLimit);
//    VTSessionSetProperty(encodingSession, kVTCompressionPropertyKey_DataRateLimits, bitRateLimitRef);
    
    [self commitStateTransition];
    return YES;
}

- (BOOL)run {
    if (![super run]) {
        [self rollbackStateTransition];
        return NO;
    }
    
    if (_compressionSession != NULL) {
        OSStatus ret = VTCompressionSessionPrepareToEncodeFrames(_compressionSession);
        if (ret != 0) {
#if DEBUG
            NSLog(@"[ENCODER][VT]: could not prepare to encode frames");
#endif
            [self rollbackStateTransition];
            return NO;
        }
        [self commitStateTransition];
        return YES;
    }
    return NO;
}

- (BOOL)invalidate {
    if (![super invalidate]) {
        [self rollbackStateTransition];
        return NO;
    }
    
    if (_compressionSession != NULL) {
        VTCompressionSessionInvalidate(_compressionSession);
        _compressionSession = NULL;
        return YES;
    }
    return NO;
}
@end
