//
//  VCRawH265Reader.m
//  VideoCodecKit
//
//  Created by CmST0us on 2020/1/27.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import <CoreMedia/CoreMedia.h>
#import "VCRawH265Reader.h"
#import "VCAVCFormatStream.h"
#import "VCAnnexBFormatParser.h"
#import "VCAnnexBFormatStream.h"
#import "VCAVCFormatStream.h"
#import "VCH265NALU.h"

#define kVCRawH265ReaderStreamReadBufferSize (40960)

@interface VCRawH265Reader ()
@property (nonatomic, strong) VCAnnexBFormatParser *annexBFormatParser;
@property (nonatomic, strong) NSInputStream *inputStream;

@property (nonatomic, assign) NSUInteger frameCount;

@property (nonatomic, assign) void *inputStreamReadBuffer;
@property (nonatomic, strong) NSData *inputStreamReadBufferData;

@property (nonatomic, strong) dispatch_queue_t readQueue;
@property (nonatomic, assign) BOOL isReading;

@property (nonatomic, strong) NSData *ppsData;
@property (nonatomic, strong) NSData *spsData;
@property (nonatomic, strong) NSData *vpsData;

@property (nonatomic, strong) VCSampleBuffer *cachedSampleBuffer;
@end

@implementation VCRawH265Reader

- (instancetype)initWithURL:(NSURL *)fileURL {
    self = [super init];
    if (self) {
        _inputStream = [[NSInputStream alloc] initWithURL:fileURL];
        _annexBFormatParser = [[VCAnnexBFormatParser alloc] init];
        _inputStreamReadBuffer = malloc(kVCRawH265ReaderStreamReadBufferSize);
        _inputStreamReadBufferData = [[NSData alloc] initWithBytesNoCopy:_inputStreamReadBuffer length:kVCRawH265ReaderStreamReadBufferSize freeWhenDone:YES];
        _readQueue = dispatch_queue_create("VCRawH265Reader::readQueue", DISPATCH_QUEUE_SERIAL);
        _isReading = NO;
        _frameCount = 0;
    }
    return self;
}

- (void)startReading {
    if (self.inputStream.streamStatus == NSStreamStatusReading ||
        self.inputStream.streamStatus == NSStreamStatusAtEnd ||
        self.inputStream.streamStatus == NSStreamStatusClosed) {
        return;
    }
    
    if (self.inputStream.streamStatus == NSStreamStatusNotOpen) {
        [self.inputStream open];
    }
    
    self.isReading = YES;
    [self doReading];
}

- (void)dealloc {
    if (_videoFormatDescription) {
        CFRelease(_videoFormatDescription);
        _videoFormatDescription = NULL;
    }
}

- (void)doReading {
    dispatch_async(self.readQueue, ^{
        @autoreleasepool {
            if (!self.isReading) {
                return;
            }
            if ([self.inputStream hasBytesAvailable] == NO) {
                return;
            }
            
            NSInteger readLen = [self.inputStream read:self.inputStreamReadBuffer maxLength:kVCRawH265ReaderStreamReadBufferSize];
            NSData *readData = [[NSData alloc] initWithBytesNoCopy:self.inputStreamReadBuffer length:readLen freeWhenDone:NO];
            [self.annexBFormatParser appendData:readData];
            VCAnnexBFormatStream *annexBFormatFrame = [self.annexBFormatParser next];
            
            while (annexBFormatFrame != nil) {
                VCAVCFormatStream *avcFormatFrame = [annexBFormatFrame toAVCFormatStream];
                avcFormatFrame.naluClass = [VCH265NALU class];
                [[avcFormatFrame nalus] enumerateObjectsUsingBlock:^(VCH265NALU * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    VCH265NALUType naluType = obj.type;
                    NSLog(@"nalu: %@", obj);
                    if (naluType == VCH265NALUTypePPS) {
                        self.ppsData = obj.data;
                    } else if (naluType == VCH265NALUTypeSPS) {
                        self.spsData = obj.data;
                    } else if (naluType == VCH265NALUTypeVPS) {
                        self.vpsData = obj.data;
                    } else if (naluType == VCH265NALUTypeSEI) {
                        
                    } else if (naluType == VCH265NALUTypeSliceN ||
                               naluType == VCH265NALUTypeIDR ||
                               naluType == VCH265NALUTypeSliceR ||
                               naluType == VCH265NALUTypeCRA){
                        if (naluType == VCH265NALUTypeIDR ||
                            naluType == VCH265NALUTypeCRA) {
                            if ([self createFormatDescription]) {
                                if (self.delegate &&
                                    [self.delegate respondsToSelector:@selector(reader:didGetVideoFormatDescription:)]) {
                                    [self.delegate reader:self didGetVideoFormatDescription:self.videoFormatDescription];
                                }
                            }
                        }
                        NSData *data = [obj warpAVCStartCode];
                        CMBlockBufferRef blockBuffer = [self createBlockBufferWithData:data];
                        CMSampleTimingInfo timingInfo;
                        timingInfo.duration = kCMTimeInvalid;
                        timingInfo.decodeTimeStamp = kCMTimeInvalid;
                        timingInfo.presentationTimeStamp = CMTimeMake(self.frameCount, 1);
                        VCSampleBuffer *sampleBuffer = [self createSampleBufferWithBlockBuffer:blockBuffer
                                                                                    timingInfo:timingInfo description:self.videoFormatDescription];
                        CFRelease(blockBuffer);
                        
                        if (self.delegate &&
                            [self.delegate respondsToSelector:@selector(reader:didGetVideoSampleBuffer:)]) {
                            [self.delegate reader:self didGetVideoSampleBuffer:sampleBuffer];
                        }
                        
                        self.frameCount += 1;
                    }
                }];
                annexBFormatFrame = [self.annexBFormatParser next];
            }
            
            [self doReading];
        }
    });
}

- (void)stopReading {
    self.isReading = NO;
}

- (BOOL)createFormatDescription {
    if (self.ppsData == nil ||
        self.spsData == nil ||
        self.vpsData == nil) {
        return NO;
    }
    
    const uint8_t *parameterSets[] = {
        (const uint8_t *)[self.vpsData bytes],
        (const uint8_t *)[self.spsData bytes],
        (const uint8_t *)[self.ppsData bytes],
    };
    
    size_t parameterSetSizes[] = {
        self.vpsData.length,
        self.spsData.length,
        self.ppsData.length
    };
    
    CMFormatDescriptionRef format;
    OSStatus ret = CMVideoFormatDescriptionCreateFromHEVCParameterSets(kCFAllocatorDefault,
                                                                       3,
                                                                       parameterSets,
                                                                       parameterSetSizes,
                                                                       4,
                                                                       NULL,
                                                                       &format);
    if (ret == noErr) {
        if (_videoFormatDescription) {
            CFRelease(_videoFormatDescription);
            _videoFormatDescription = NULL;
        }
        _videoFormatDescription = format;
        return YES;
    }
    return NO;
}

- (VCSampleBuffer *)createSampleBufferWithBlockBuffer:(CMBlockBufferRef)blockBuffer
                                           timingInfo:(CMSampleTimingInfo)timingInfo
                                          description:(CMFormatDescriptionRef)description {
    CMSampleBufferRef sampleBuffer = nil;
    size_t blockDataSizeArray[1] = {CMBlockBufferGetDataLength(blockBuffer)};
    OSStatus ret = CMSampleBufferCreateReady(kCFAllocatorDefault,
                                    blockBuffer,
                                    description,
                                    1,
                                    1,
                                    &timingInfo,
                                    1,
                                    blockDataSizeArray,
                                    &sampleBuffer);
    if (ret != noErr) {
        return nil;
    }
    return [[VCSampleBuffer alloc] initWithSampleBuffer:sampleBuffer];
}

- (CMBlockBufferRef)createBlockBufferWithData:(NSData *)data {
    CMBlockBufferRef blockBuffer = nil;
    OSStatus ret = CMBlockBufferCreateWithMemoryBlock(kCFAllocatorDefault,
                                                      (void *)data.bytes,
                                                      data.length,
                                                      kCFAllocatorNull,
                                                      NULL,
                                                      0,
                                                      data.length,
                                                      0,
                                                      &blockBuffer);
    if (ret != noErr) {
        // skip this tag
        return nil;
    }
    return blockBuffer;
}
@end
