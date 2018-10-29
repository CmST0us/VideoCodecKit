//
//  VCVTH264Decoder.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/22.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <VideoToolbox/VideoToolbox.h>
#import <pthread.h>
#import "VCVTH264Decoder.h"
#import "VCH264Frame.h"
#import "VCYUV420PImage.h"
#import "VCPriorityObjectQueue.h"
#import "VCH264SPSFrame.h"
#import "VCH264PPSFrame.h"
@interface VCVTH264Decoder () {
    CMVideoFormatDescriptionRef _videoFormatDescription;
    VTDecompressionSessionRef _decodeSession;
    
    NSInteger _startCodeSize;
    
    BOOL _isVideoFormatDescriptionUpdate;
    pthread_mutex_t _decoderLock;
}

@end

@implementation VCVTH264Decoder

static void decompressionOutputCallback(void *decompressionOutputRefCon,
                                        void *sourceFrameRefCon,
                                        OSStatus status,
                                        VTDecodeInfoFlags infoFlags,
                                        CVImageBufferRef imageBuffer,
                                        CMTime presentationTimeStamp,
                                        CMTime presentationDuration) {
    CVPixelBufferRef *outputPixelBuffer = (CVPixelBufferRef *)sourceFrameRefCon;
    *outputPixelBuffer = CVPixelBufferRetain(imageBuffer);
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _videoFormatDescription = NULL;
        _decodeSession = NULL;
        _currentPPSFrame = nil;
        _currentSPSFrame = nil;
        pthread_mutex_init(&_decoderLock, NULL);
        _isVideoFormatDescriptionUpdate = NO;
    }
    return self;
}

- (void)dealloc {
    [self freeVideoFormatDescription];
    [self freeDecodeSession];
    pthread_mutex_destroy(&_decoderLock);
}

#pragma mark - Decoder Public Method
- (BOOL)setup {
    if ([super setup]) {
        pthread_mutex_lock(&_decoderLock);
        [self commitStateTransition];
        pthread_mutex_unlock(&_decoderLock);
        return YES;
    }
    [self rollbackStateTransition];
    return NO;
}

- (BOOL)invalidate {
    if ([super invalidate]) {
        pthread_mutex_lock(&_decoderLock);
        [self commitStateTransition];
        
        [self freeDecodeSession];
        [self freeVideoFormatDescription];
        pthread_mutex_unlock(&_decoderLock);
        return YES;
    }
    [self rollbackStateTransition];
    return NO;
}

#pragma mark - Decoder Private Method

- (void)freeDecodeSession {
    if (_decodeSession != NULL) {
        VTDecompressionSessionInvalidate(_decodeSession);
        CFRelease(_decodeSession);
        _decodeSession = NULL;
    }
}

- (void)freeVideoFormatDescription {
    if (_videoFormatDescription != NULL) {
        CFRelease(_videoFormatDescription);
        _videoFormatDescription = NULL;
    }
}

- (BOOL)setupVideoFormatDescription {
    [self freeVideoFormatDescription];
    
    const uint8_t *para[2] = {_currentSPSFrame.parseData + _currentSPSFrame.startCodeSize, _currentPPSFrame.parseData + _currentPPSFrame.startCodeSize};
    const size_t paraSize[2] = {_currentSPSFrame.parseSize - _currentSPSFrame.startCodeSize, _currentPPSFrame.parseSize - _currentPPSFrame.startCodeSize};
    
    OSStatus ret = CMVideoFormatDescriptionCreateFromH264ParameterSets(kCFAllocatorDefault,
                                                                       2,
                                                                       para,
                                                                       paraSize,
                                                                       4,
                                                                       &_videoFormatDescription);
    if (ret == 0) {
        return YES;
    }
    return NO;
}

- (BOOL)setupDecompressionSession {
    if (_videoFormatDescription == NULL) return NO;
    [self freeDecodeSession];
    
    //get width and height of video
    CMVideoDimensions dimension = CMVideoFormatDescriptionGetDimensions (_videoFormatDescription);
    
    // Set the pixel attributes for the destination buffer
    CFMutableDictionaryRef destinationPixelBufferAttributes = CFDictionaryCreateMutable(
                                                                                        kCFAllocatorDefault,
                                                                                        0,
                                                                                        &kCFTypeDictionaryKeyCallBacks,
                                                                                        &kCFTypeDictionaryValueCallBacks);
    
    SInt32 destinationPixelType = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange;
    
    CFNumberRef pixelType = CFNumberCreate(NULL, kCFNumberSInt32Type, &destinationPixelType);
    CFDictionarySetValue(destinationPixelBufferAttributes,kCVPixelBufferPixelFormatTypeKey, pixelType);
    CFRelease(pixelType);
    
    CFNumberRef width = CFNumberCreate(NULL, kCFNumberSInt32Type, &dimension.width);
    CFDictionarySetValue(destinationPixelBufferAttributes,kCVPixelBufferWidthKey, width);
    CFRelease(width);
    
    CFNumberRef height = CFNumberCreate(NULL, kCFNumberSInt32Type, &dimension.height);
    CFDictionarySetValue(destinationPixelBufferAttributes, kCVPixelBufferHeightKey, height);
    CFRelease(height);
    
//    CFDictionarySetValue(destinationPixelBufferAttributes, kCVPixelBufferOpenGLCompatibilityKey, kCFBooleanTrue);
    
    VTDecompressionOutputCallbackRecord callbackRecord;
    callbackRecord.decompressionOutputCallback = decompressionOutputCallback;
    callbackRecord.decompressionOutputRefCon = NULL;
    
    OSStatus ret = VTDecompressionSessionCreate(kCFAllocatorDefault,
                                 _videoFormatDescription,
                                 NULL,
                                 destinationPixelBufferAttributes,
                                 &callbackRecord,
                                 &_decodeSession);
    CFRelease(destinationPixelBufferAttributes);
    
    if (ret == 0) {
        return YES;
    }
    return NO;
}

- (BOOL)useSpsPpsFromKeyFrame:(VCH264Frame *)frame
              nextFrameOffset:(NSInteger *)offset{
    if (!frame.isKeyFrame) return NO;
    
    BOOL updateSPS = NO;
    BOOL updatePPS = NO;
    NSDictionary *offsetDict = [self findAllFrameNaulOffset:frame];
    if ([offsetDict count] < 3) return NO;
    NSArray *sortOffsetKeys = [offsetDict.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if ([obj1 integerValue] > [obj2 integerValue]) return NSOrderedDescending;
        if ([obj1 integerValue] < [obj2 integerValue]) return NSOrderedAscending;
        return NSOrderedSame;
    }];
    
    // 默认keyFrame为 |SPS|PPS|... 顺序
    NSNumber *spsOffset = sortOffsetKeys[0];
    NSNumber *ppsOffset = sortOffsetKeys[1];
    NSNumber *nextOffset = sortOffsetKeys[2];
    
    NSNumber *spsSize = offsetDict[spsOffset];
    NSNumber *ppsSize = offsetDict[ppsOffset];
    
    // check if frame is sps
    _currentSPSFrame = [[VCH264SPSFrame alloc] initWithWidth:frame.width height:frame.height];
    [_currentSPSFrame createParseDataWithSize:spsSize.integerValue];
    memcpy(_currentSPSFrame.parseData, frame.parseData + spsOffset.integerValue, spsSize.integerValue);
    _currentSPSFrame.frameType = [VCH264Frame getFrameType:_currentSPSFrame];
    updateSPS = YES;
    
    _currentPPSFrame = [[VCH264PPSFrame alloc] initWithWidth:frame.width height:frame.height];
    [_currentPPSFrame createParseDataWithSize:ppsSize.integerValue];
    memcpy(_currentPPSFrame.parseData, frame.parseData + ppsOffset.integerValue, ppsSize.integerValue);
    _currentPPSFrame.frameType = [VCH264Frame getFrameType:_currentPPSFrame];
    updatePPS = YES;

    *offset = nextOffset.integerValue;
    return updateSPS && updatePPS;
}

- (NSDictionary<NSNumber *, NSNumber *> *)findAllFrameNaulOffset:(VCH264Frame *)frame {
    NSMutableDictionary *offsetDict = [NSMutableDictionary dictionary];
    NSInteger lastIndex = 0;
    for (NSInteger i = frame.startCodeSize; i < frame.parseSize - 4; i++) {
        static uint8_t startCode1[4] = {0x00, 0x00, 0x00, 0x01};
        static uint8_t startCode2[3] = {0x00, 0x00, 0x01};
        if (memcmp(frame.parseData + i, startCode1, sizeof(startCode1)) == 0) {
            offsetDict[@(lastIndex)] = @(i - lastIndex);
            lastIndex = i;
            i += 3;
        }
        if(memcmp(frame.parseData + i, startCode2, sizeof(startCode2)) == 0) {
            offsetDict[@(lastIndex)] = @(i - lastIndex);
            lastIndex = i;
            i += 3;
        }
    }
    if (lastIndex < frame.parseSize) {
        offsetDict[@(lastIndex)] = @(frame.parseSize - lastIndex);
    }
    return offsetDict;
}

- (VCBaseImage *)decodeSingleFrame:(VCH264Frame *)frame {

    if (self.currentState.unsignedIntegerValue != VCBaseCodecStateRunning) return nil;
    if (![[frame class] isSubclassOfClass:[VCH264Frame class]]) return nil;

    VCH264Frame *h264Frame = (VCH264Frame *)frame;
    if (h264Frame.startCodeSize < 0) return nil;
    pthread_mutex_lock(&_decoderLock);
    _startCodeSize = h264Frame.startCodeSize;
    if (_startCodeSize == 3) {
        [h264Frame useExternParseDataLength:1];
        h264Frame.startCodeSize = 4;
        _startCodeSize = 4;
    }
    uint32_t nalSize = (uint32_t)(h264Frame.parseSize - _startCodeSize);
    uint32_t *pNalSize = (uint32_t *)h264Frame.parseData;
    *pNalSize = CFSwapInt32HostToBig(nalSize);
    
    if (h264Frame.frameType == VCH264FrameTypeIDR) {
        if (_isVideoFormatDescriptionUpdate) {
            if (![self setupVideoFormatDescription]) {
                _isVideoFormatDescriptionUpdate = YES;
            } else {
                if ([self setupDecompressionSession]) {
                    _isVideoFormatDescriptionUpdate = NO;
                }
            }
        }
    }
    if (_videoFormatDescription == NULL) {
        pthread_mutex_unlock(&_decoderLock);
        return nil;
    }
    // decode process
    CMBlockBufferRef blockBuffer = NULL;
    CVPixelBufferRef outputPixelBuffer = NULL;
    OSStatus ret = CMBlockBufferCreateWithMemoryBlock(kCFAllocatorDefault,
                                                      h264Frame.parseData,
                                                      h264Frame.parseSize,
                                                      kCFAllocatorNull,
                                                      NULL,
                                                      0,
                                                      h264Frame.parseSize,
                                                      0,
                                                      &blockBuffer);
    if (ret == kCMBlockBufferNoErr) {
        // decode success
        CMSampleBufferRef sampleBuffer = NULL;
        const size_t sampleSizeArray[] = {h264Frame.parseSize};
        
        ret = CMSampleBufferCreateReady(kCFAllocatorDefault,
                                        blockBuffer,
                                        _videoFormatDescription,
                                        1,
                                        0,
                                        NULL,
                                        1,
                                        sampleSizeArray,
                                        &sampleBuffer);
        
        if (ret == kCMBlockBufferNoErr && sampleBuffer) {
            VTDecodeFrameFlags flags = 0;
            VTDecodeInfoFlags flagOut = 0;
            OSStatus decodeStatus = VTDecompressionSessionDecodeFrame(_decodeSession,
                                                                      sampleBuffer,
                                                                      flags,
                                                                      &outputPixelBuffer,
                                                                      &flagOut);
            if (decodeStatus == kVTInvalidSessionErr) {
                [self setupDecompressionSession];
            }
            CFRelease(sampleBuffer);
            sampleBuffer = NULL;
        }
        CFRelease(blockBuffer);
        blockBuffer = NULL;
    }
    
    if (outputPixelBuffer == NULL) {
        pthread_mutex_unlock(&_decoderLock);
        return nil;
    }
    
    VCYUV420PImage *image = [[VCYUV420PImage alloc] initWithWidth:h264Frame.width height:h264Frame.height];
    [image.userInfo setObject:@(h264Frame.frameIndex) forKey:kVCBaseImageUserInfoFrameIndexKey];
    if (h264Frame.frameType == VCH264FrameTypeIDR) {
        [image.userInfo setObject:@(kVCPriorityIDR) forKey:kVCBaseImageUserInfoFrameIndexKey];
    }
    
    [image setPixelBuffer:outputPixelBuffer];
    
    CVPixelBufferRelease(outputPixelBuffer);
    pthread_mutex_unlock(&_decoderLock);
    return image;
}

- (void)decodeWithFrame:(VCBaseFrame *)frame {
    [self decodeFrame:frame completion:^(VCBaseImage *image) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(decoder:didProcessImage:)]) {
            [self.delegate decoder:self didProcessImage:image];
        }
    }];
}

- (void)decodeFrame:(VCBaseFrame *)frame completion:(void (^)(VCBaseImage *))block {
    if (self.currentState.unsignedIntegerValue != VCBaseCodecStateRunning) return;
    if (![[frame class] isSubclassOfClass:[VCH264Frame class]]) return;
    VCH264Frame *decodeFrame = (VCH264Frame *)frame;
    if (decodeFrame.startCodeSize < 0) return;
    // 解帧
    if (decodeFrame.isKeyFrame) {
        // 关键帧提取SPS PPS
        NSInteger nextOffset = 0;
        BOOL isUsedSpsPps = [self useSpsPpsFromKeyFrame:decodeFrame nextFrameOffset:&nextOffset];
        if (isUsedSpsPps) {
            if (![self setupVideoFormatDescription]) {
                _isVideoFormatDescriptionUpdate = YES;
            } else {
                if ([self setupDecompressionSession]) {
                    _isVideoFormatDescriptionUpdate = NO;
                }
            }
        } else {
            return;
        }
        // use offset
        decodeFrame.parseData += nextOffset;
        decodeFrame.parseSize -= nextOffset;
    }
    NSDictionary *offsetDict = [self findAllFrameNaulOffset:decodeFrame];
    NSArray *sortOffsetKeys = [offsetDict.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if ([obj1 integerValue] > [obj2 integerValue]) return NSOrderedDescending;
        if ([obj1 integerValue] < [obj2 integerValue]) return NSOrderedAscending;
        return NSOrderedSame;
    }];
    for (NSNumber *offset in sortOffsetKeys) {
        NSNumber *size = offsetDict[offset];
        VCH264Frame *f = [[VCH264Frame alloc] initWithWidth:frame.width height:frame.height];
        f.frameIndex = decodeFrame.frameIndex;
        [f createParseDataWithSize:size.integerValue];
        memcpy(f.parseData, frame.parseData + offset.integerValue, size.integerValue);
        f.frameType = [VCH264Frame getFrameType:f];
        if (f.frameType == VCH264FrameTypeSEI) {
            continue;
        }
        VCBaseImage *image = [self decodeSingleFrame:f];
        if (block) {
            block(image);
        }
    }
}

@end
