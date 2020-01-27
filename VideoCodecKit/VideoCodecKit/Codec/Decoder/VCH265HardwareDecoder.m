//
//  VCH265HardwareDecoder.m
//  VideoCodecKit
//
//  Created by CmST0us on 2020/1/23.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import <VideoToolbox/VideoToolbox.h>
#import "VCH265HardwareDecoder.h"

#define kVCH265HardwareDecoderMinGOPCount (3)

@interface VCH265HardwareDecoder ()
@property (nonatomic, strong) NSMutableArray<VCSampleBuffer *> *decodeBuffer;
@property (nonatomic) CMFormatDescriptionRef formatDescription;
@property (nonatomic) VTDecompressionSessionRef session;

@property (nonatomic, assign) BOOL isBaseline;
@property (nonatomic, assign) BOOL shouldClearDecodeBuffer;
@end

@implementation VCH265HardwareDecoder
@synthesize session = _session;

#pragma mark - Callback
static void decompressionOutputCallback(void *decompressionOutputRefCon,
                                        void *sourceFrameRefCon,
                                        OSStatus status,
                                        VTDecodeInfoFlags infoFlags,
                                        CVImageBufferRef imageBuffer,
                                        CMTime presentationTimeStamp,
                                        CMTime presentationDuration) {
    VCH265HardwareDecoder *decoder = (__bridge VCH265HardwareDecoder *)decompressionOutputRefCon;
    if (decoder == nil) return;
    [decoder decodeSessionDidOuputWithStatus:status infoFlags:infoFlags imageBuffer:imageBuffer presentationTimeStamp:presentationTimeStamp duration:presentationDuration];
}

#pragma mark - Init
- (instancetype)init {
    self = [super init];
    if (self) {
        _decodeBuffer = [NSMutableArray arrayWithCapacity:kVCH265HardwareDecoderMinGOPCount];
        _attributes = [VCH265HardwareDecoder defaultAttributes];
        
        _formatDescription = NULL;
    }
    return self;
}

- (void)dealloc {

    if (_session != NULL) {
        VTDecompressionSessionFinishDelayedFrames(_session);
        VTDecompressionSessionWaitForAsynchronousFrames(_session);
        VTDecompressionSessionInvalidate(_session);
        CFRelease(_session);
//        _session = NULL;
    }
    
    if (_formatDescription != NULL) {
        CFRelease(_formatDescription);
        _formatDescription = NULL;
    }
}
#pragma mark - Getter Setter
- (void)setFormatDescription:(CMFormatDescriptionRef)formatDescription {
    if (!CMFormatDescriptionEqual(_formatDescription, formatDescription)) {
        // [TODO] 编写解析器解析额外的avcC数据
        // [TODO] 如果没有avcC数据, 则流为Annex-B，掉对应解析器解析。
        // 判断是否为baseline
    }
    _formatDescription = CFRetain(formatDescription);
}

+ (NSDictionary *)defaultAttributes {
    return @{
#if (TARGET_OS_IOS)
             (NSString *)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange),
             (NSString *)kCVPixelBufferIOSurfacePropertiesKey: @{},
             (NSString *)kCVPixelBufferOpenGLCompatibilityKey: @(YES),
             (NSString *)kCVPixelBufferMetalCompatibilityKey: @(YES)
#else
             (NSString *)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange),
             (NSString *)kCVPixelBufferIOSurfacePropertiesKey: @{},
             (NSString *)kCVPixelBufferOpenGLCompatibilityKey: @(YES),
#endif
             };
}

- (VTDecompressionSessionRef)session {
    if (_session != nil) {
        return _session;
    }
    
    if (_formatDescription == nil) {
        return nil;
    }
    
    VTDecompressionOutputCallbackRecord callbackRecord;
    callbackRecord.decompressionOutputRefCon = (__bridge void * _Nullable)(self);
    callbackRecord.decompressionOutputCallback = decompressionOutputCallback;
    
    CFDictionaryRef attributes = (__bridge CFDictionaryRef)self.attributes;
    OSStatus ret = VTDecompressionSessionCreate(kCFAllocatorDefault,
                                                _formatDescription,
                                                nil,
                                                attributes,
                                                &callbackRecord,
                                                &_session);
    if (ret != noErr) {
        return nil;
    }
    return _session;
}

- (void)setSession:(VTDecompressionSessionRef)session {
    VTDecompressionSessionFinishDelayedFrames(_session);
    VTDecompressionSessionInvalidate(_session);
    _session = session;
}

#pragma mark - Decode Method
- (void)decodeSessionDidOuputWithStatus:(OSStatus)status
                              infoFlags:(VTDecodeInfoFlags)infoFlags
                            imageBuffer:(nullable CVImageBufferRef)imageBuffer
                  presentationTimeStamp:(CMTime)presentationTimeStamp
                               duration:(CMTime)duration {
    if (status != noErr ||
        imageBuffer == nil) {
        return;
    }
    
    OSStatus ret;
    
    CMSampleTimingInfo timingInfo;
    timingInfo.duration = duration;
    timingInfo.presentationTimeStamp = presentationTimeStamp;
    timingInfo.decodeTimeStamp = kCMTimeInvalid;
    
    CMVideoFormatDescriptionRef videoFormatDescription = NULL;
    ret = CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault,
                                                       imageBuffer,
                                                       &videoFormatDescription);
    if (ret != noErr) {
        return;
    }
    
    CMSampleBufferRef sampleBuffer;
    ret = CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault,
                                       imageBuffer,
                                       true,
                                       nil,
                                       nil,
                                       videoFormatDescription,
                                       &timingInfo,
                                       &sampleBuffer);
    CFRelease(videoFormatDescription);
    if (ret != noErr) {
        return;
    }
    
    if (sampleBuffer == nil) {
        return;
    }
    
    VCSampleBuffer *outputSampleBuffer = [[VCSampleBuffer alloc] initWithSampleBuffer:sampleBuffer];
    
    if (self.isBaseline) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(videoDecoder:didOutputSampleBuffer:)]) {
            [self.delegate videoDecoder:self didOutputSampleBuffer:outputSampleBuffer];
        }
    } else {
        [self.decodeBuffer addObject:outputSampleBuffer];
        [self.decodeBuffer sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return CMTimeCompare([obj1 presentationTimeStamp], [obj2 presentationTimeStamp]) <= 0;
        }];
        if (self.decodeBuffer.count >= kVCH265HardwareDecoderMinGOPCount) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(videoDecoder:didOutputSampleBuffer:)]) {
                [self.delegate videoDecoder:self didOutputSampleBuffer:self.decodeBuffer[0]];
            }
            [self.decodeBuffer removeObjectAtIndex:0];
        }
    }
    
    if (_shouldClearDecodeBuffer) {
        [self.decodeBuffer removeAllObjects];
        _shouldClearDecodeBuffer = NO;
    }
}

- (OSStatus)decodeSampleBuffer:(VCSampleBuffer *)sampleBuffer {
    if (self.session == nil) {
        return kVTInvalidSessionErr;
    }
    // [TODO] kVTDecodeFrame_EnableTemporalProcessing 判断是否需要加
    VTDecodeFrameFlags flags = kVTDecodeFrame_EnableAsynchronousDecompression;
    return VTDecompressionSessionDecodeFrame(self.session, sampleBuffer.sampleBuffer, flags, nil, nil);
}

- (void)clear {
    _shouldClearDecodeBuffer = YES;
}


@end
