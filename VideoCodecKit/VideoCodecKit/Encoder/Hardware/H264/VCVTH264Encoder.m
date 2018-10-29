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
#import "VCBaseImage.h"
#import "VCH264Frame.h"
#import "VCH264SPSFrame.h"

@interface VCVTH264Encoder ()
@property (nonatomic, assign) VTCompressionSessionRef compressionSession;
@property (nonatomic, strong) VCH264SPSFrame *sps; // [TODO]: 改为VCH264SPSFrame
@property (nonatomic, strong) VCH264PPSFrame *pps; // [TODO]: 改为VCH264PPSFrame
@end

@implementation VCVTH264Encoder

void outputCallback(void * CM_NULLABLE outputCallbackRefCon,
                                 void * CM_NULLABLE sourceFrameRefCon,
                                 OSStatus status,
                                 VTEncodeInfoFlags infoFlags,
                                 CM_NULLABLE CMSampleBufferRef sampleBuffer) {
#if DEBUG
    NSLog(@"[ENCODER][VT]: encoder callback with status %d, infoFlags %d", (int)status, (int)infoFlags);
#endif
    
    if (infoFlags == 0) {
#if DEBUG
        // 似乎是VT的一个bug，如果你在Serial dispatch_queue中调用编码函数，这个infoFlags可能为0，从而导致编码出来的NAL顺序错误！
        // [TODO] 进一步验证是不是VT的bug
        NSLog(@"[ENCODER][VT]: did not support sync info flags!");
#endif
        return;
    }

    if (status != noErr) {
        return;
    }
    
    if (!(CMSampleBufferDataIsReady(sampleBuffer))) {
#if DEBUG
        NSLog(@"[ENCODER][VT]: sample buffer is not ready");
#endif
        return;
    }
    
    VCVTH264Encoder *encoder = (__bridge VCVTH264Encoder *)outputCallbackRefCon;
    BOOL isKeyFrame = !CFDictionaryContainsKey(
                                              CFArrayGetValueAtIndex(CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, true), 0),
                                              kCMSampleAttachmentKey_NotSync
                                              );
    if (isKeyFrame) {
#if DEBUG
        NSLog(@"[ENCODER][VT]: key frame");
#endif
        // SPS
        CMFormatDescriptionRef format = CMSampleBufferGetFormatDescription(sampleBuffer);
        size_t sparameterSetSize, sparameterSetCount;
        const uint8_t *sparameterSet;
        OSStatus statusCode = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format,
                                                                                 0,
                                                                                 &sparameterSet,
                                                                                 &sparameterSetSize,
                                                                                 &sparameterSetCount,
                                                                                 0);
        if (statusCode == noErr) {
#if DEBUG
            NSLog(@"[ENCODER][VT]: get sps");
#endif
            // PPS
            CMFormatDescriptionRef format = CMSampleBufferGetFormatDescription(sampleBuffer);
            size_t pparameterSetSize, pparameterSetCount;
            const uint8_t *pparameterSet;
            OSStatus statusCode = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format,
                                                                                     1,
                                                                                     &pparameterSet,
                                                                                     &pparameterSetSize,
                                                                                     &pparameterSetCount,
                                                                                     0);
            if (statusCode == noErr) {
#if DEBUG
                NSLog(@"[ENCODER][VT]: get pps");
#endif
                // USE SPS PPS
                NSData *sps = [NSData dataWithBytes:sparameterSet length:sparameterSetSize];
                NSData *pps = [NSData dataWithBytes:pparameterSet length:pparameterSetSize];
                
                if (encoder) {
                    [encoder useSPS:sps];
                    [encoder usePPS:pps];
                    if (encoder.delegate
                        && [encoder.delegate respondsToSelector:@selector(encoder:didProcessFrame:)]) {
                        [encoder.delegate encoder:encoder didProcessFrame:encoder.sps];
                        [encoder.delegate encoder:encoder didProcessFrame:encoder.pps];
                    }
                }
            }
        }
    }
    
    // GET Slice
    CMBlockBufferRef dataBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    size_t length, totalLength;
    char *dataPtr;
    
    OSStatus ret = CMBlockBufferGetDataPointer(dataBuffer, 0, &length, &totalLength, &dataPtr);
    if (ret == noErr) {
        size_t bufferOffset = 0;
        
        while (bufferOffset < totalLength - 4) {
            @autoreleasepool {
                uint32_t naulLength = *((uint32_t *)((uint8_t *)dataPtr + bufferOffset));
                naulLength = CFSwapInt32BigToHost(naulLength);
                VCH264Frame *frame = [[VCH264Frame alloc] init];
                [frame createParseDataWithSize:naulLength];
                [frame useExternParseDataLength:4];
                *(frame.parseData + 3) = 1;
                memcpy(frame.parseData + 4, dataPtr + bufferOffset + 4, naulLength);
                
                frame.frameType = [VCH264Frame getFrameType:frame];
                
                if (encoder && encoder.delegate) {
                    if ([encoder.delegate respondsToSelector:@selector(encoder:didProcessFrame:)]) {
                        [encoder.delegate encoder:encoder didProcessFrame:frame];
                    }
                }
                bufferOffset += (4 + naulLength);
            }
        }
    }
}

- (instancetype)initWithConfig:(VCH264EncoderConfig *)config {
    self = [super init];
    if (self) {
        _compressionSession = nil;
        _config = config;
    }
    return self;
}

#pragma mark - Codec Method
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
    
    VTSessionSetProperty(_compressionSession,
                         kVTCompressionPropertyKey_AllowFrameReordering,
                         self.config.enableBFrame ? kCFBooleanTrue : kCFBooleanFalse);
    
    switch (self.config.quality) {
        case VCH264EncoderQualityNormal:
            VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_ProfileLevel, kVTProfileLevel_H264_Main_AutoLevel);
            break;
        case VCH264EncoderQualityFast:
            VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_ProfileLevel, kVTProfileLevel_H264_Baseline_AutoLevel);
            break;
        case VCH264EncoderQualityGood:
            VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_ProfileLevel, kVTProfileLevel_H264_High_AutoLevel);
            break;
        case VCH264EncoderQualitySplendid:
            VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_ProfileLevel, kVTProfileLevel_H264_Extended_AutoLevel);
            break;
        default:
            break;
    }
    
    NSInteger keyFrameIntervalDuration = self.config.keyFrameIntervalDuration;
    CFNumberRef keyFrameIntervalDurationRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &keyFrameIntervalDuration);
    VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_MaxKeyFrameIntervalDuration, keyFrameIntervalDurationRef);
    
    NSInteger keyFrameInterval = self.config.keyFrameInterval;
    CFNumberRef keyFrameIntervalRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &keyFrameInterval);
    VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_MaxKeyFrameInterval, keyFrameIntervalRef);
    
    NSInteger fps = self.config.fps;
    CFNumberRef fpsRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &fps);
    VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_ExpectedFrameRate, fpsRef);
    
    NSInteger bitrate = self.config.bitrate;
    CFNumberRef bitRateRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &bitrate);
    VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_AverageBitRate, bitRateRef);
    
    //设置码率，上限，单位是bps
    int bitRateLimit = (int)(self.config.width * self.config.height * 3 * 4);
    CFNumberRef bitRateLimitRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &bitRateLimit);
    VTSessionSetProperty(_compressionSession, kVTCompressionPropertyKey_DataRateLimits, bitRateLimitRef);
    
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
#pragma mark - Private Method
- (void)useSPS:(NSData *)spsData {
    VCH264SPSFrame *frame = [[VCH264SPSFrame alloc] init];
    [frame createParseDataWithSize:spsData.length];
    [frame useExternParseDataLength:4];
    *(frame.parseData + 3) = 1;
    memcpy(frame.parseData + 4, spsData.bytes, spsData.length);
    frame.frameType = [VCH264Frame getFrameType:frame];
#if DEBUG
    NSLog(@"[ENCODER][VT]: sps output width %d height %d fps %d", (int)frame.outputWidth, (int)frame.outputHeight, (int)frame.fps);
#endif
    self.sps = frame;
}

- (void)usePPS:(NSData *)ppsData {
    VCH264PPSFrame *frame = [[VCH264PPSFrame alloc] init];
    [frame createParseDataWithSize:ppsData.length];
    [frame useExternParseDataLength:4];
    *(frame.parseData + 3) = 1;
    frame.frameType = [VCH264Frame getFrameType:frame];
    memcpy(frame.parseData + 4, ppsData.bytes, ppsData.length);
    self.pps = frame;
}

#pragma mark - Protocol Method
- (void)encodeWithImage:(VCBaseImage *)image {
    if (![self.currentState isEqualToInteger:VCBaseCodecStateRunning]) {
        return;
    }
    CMTime ptsTime = CMTimeMake(self.frameCount++, (int)self.config.fps);
    CMTime duration = CMTimeMake(1, (int)self.config.fps);
    VTEncodeInfoFlags flags;
    
    OSStatus statusCode = VTCompressionSessionEncodeFrame(self.compressionSession,
                                                          image.pixelBuffer,
                                                          ptsTime,
                                                          duration,
                                                          NULL,
                                                          NULL,
                                                          &flags);
    if (statusCode != noErr) {
#if DEBUG
        NSLog(@"[ENCODER][VT]: encode frame failed with %d", (int)statusCode);
#endif
        [self invalidate];
        return;
    }
}
@end

