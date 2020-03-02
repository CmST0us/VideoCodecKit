//
//  VCFLVReader.m
//  VideoCodecKit
//
//  Created by CmST0us on 2019/1/30.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "VCFLVReader.h"
#import "VCFLVFile.h"
#import "VCFLVTag.h"
#import "VCSampleBuffer.h"
#import "VCAVCConfigurationRecord.h"
#import "VCAudioSpecificConfig.h"

@implementation VCFLVVideoKeyFrameIndex
@end

@interface VCFLVReader ()
@property (nonatomic, strong) VCFLVFile *file;
@property (nonatomic, strong) NSThread *readThread;
@end

@implementation VCFLVReader
@synthesize keyFrameIndex = _keyFrameIndex;

- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        _file = [[VCFLVFile alloc] initWithURL:url];
        _videoFormatDescription = nil;
        _audioFormatDescription = nil;
        if (_file == nil) {
            return nil;
        }
    }
    return self;
}

- (void)dealloc {
    [self.readThread cancel];
    if (_videoFormatDescription) {
        CFRelease(_videoFormatDescription);
        _videoFormatDescription = NULL;
    }
    if (_audioFormatDescription) {
        CFRelease(_audioFormatDescription);
        _audioFormatDescription = NULL;
    }
}

- (void)createSeekTable {
    VCFLVTag *nextTag = nil;
    NSInteger fileOffset = _file.currentFileOffset;
    NSMutableArray *keyFrameIndexArray = [[NSMutableArray alloc] init];
    CMTime maxTime = CMTimeMake(0, 1000);
    do {
        nextTag = [_file nextTag];
        if (nextTag == nil) break;
        
        CMTime currentTime = CMTimeMake([nextTag extendedTimestamp], 1000);
        if (CMTimeCompare(currentTime, maxTime) == 1) {
            maxTime = currentTime;
        }
        
        if ([nextTag isKindOfClass:[VCFLVVideoTag class]]) {
            VCFLVVideoTag *videoTag = (VCFLVVideoTag *)nextTag;
            VCFLVVideoTagFrameType frameType = [videoTag frameType];
            VCFLVVideoTagAVCPacketType avcType = [videoTag AVCPacketType];
            
            if (frameType == VCFLVVideoTagFrameTypeKeyFrame &&
                avcType == VCFLVVideoTagAVCPacketTypeNALU) {
                // add to key frame array;
                NSInteger keyFrameSeek = _file.currentTagOffsetInFile;
                
                CMTime pts = CMTimeMake([videoTag presentationTimeStamp], 1000);
                
                VCFLVVideoKeyFrameIndex *index = [[VCFLVVideoKeyFrameIndex alloc] init];
                index.position = keyFrameSeek;
                index.presentationTime = pts;
                
                [keyFrameIndexArray addObject:index];
            }
        }
    } while (nextTag != nil);
    _keyFrameIndex = keyFrameIndexArray;
    _duration = maxTime;
    _file.currentFileOffset = fileOffset;
}

- (NSArray<VCFLVVideoKeyFrameIndex *> *)keyFrameIndex {
    if (_keyFrameIndex != nil) {
        return _keyFrameIndex;
    }
    [self createSeekTable];
    _keyFrameIndex = [_keyFrameIndex sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        VCFLVVideoKeyFrameIndex *index1 = (VCFLVVideoKeyFrameIndex *)obj1;
        VCFLVVideoKeyFrameIndex *index2 = (VCFLVVideoKeyFrameIndex *)obj2;
        int32_t result = CMTimeCompare(index1.presentationTime, index2.presentationTime);
        if (result == -1) {
            // index1 < index2
            return NSOrderedAscending;
        } else if (result == 0) {
            return NSOrderedSame;
        }
        return NSOrderedDescending;
    }];
    return _keyFrameIndex;
}

- (void)starAsyncReading {
    self.readThread = [[NSThread alloc] initWithTarget:self selector:@selector(startReading) object:nil];
    [self.readThread start];
}

- (void)startReading {
    @autoreleasepool {
        VCFLVTag *nextTag = nil;
        do {
            nextTag = [_file nextTag];
            if (nextTag == nil) break;
            
            if ([nextTag isKindOfClass:[VCFLVVideoTag class]]) {
                VCFLVVideoTag *videoTag = (VCFLVVideoTag *)nextTag;
                VCFLVVideoTagFrameType frameType = [videoTag frameType];
                VCFLVVideoTagAVCPacketType avcType = [videoTag AVCPacketType];
                
                if (avcType == VCFLVVideoTagAVCPacketTypeSequenceHeader) {
                    // [TODO]: parse avc record
                    VCAVCConfigurationRecord *record = [[VCAVCConfigurationRecord alloc] initWithData:videoTag.payloadData];
                    CMFormatDescriptionRef format = nil;
                    OSStatus ret = [record createFormatDescription:&format];
                    if (ret != noErr ||
                        format == nil) {
                        // can't create video format description
                        break;
                    }
                    _videoFormatDescription = format;
                    if (self.delegate &&
                        [self.delegate respondsToSelector:@selector(reader:didGetVideoFormatDescription:)]) {
                        [self.delegate reader:self didGetVideoFormatDescription:format];
                        continue;
                    }
                } else if (avcType == VCFLVVideoTagAVCPacketTypeEndOfSequence) {
                    // end of file
                    break;
                }
                
                if (frameType == VCFLVVideoTagFrameTypeVideoInfoFrame) {
                    // [TODO]: avcType == seq 时，frameType != info ?
                    
                } else if (frameType == VCFLVVideoTagFrameTypeKeyFrame ||
                           frameType == VCFLVVideoTagFrameTypeInterFrame){
                    // [TODO]: KeyFrame and Inter Frame
                    // Create Block Buffer
                    if (_videoFormatDescription == NULL) continue;
                    
                    // Create Block Buffer
                    CMBlockBufferRef blockBuffer = [self createBlockBufferWithData:videoTag.payloadData];
                    if (blockBuffer == nil) continue;
                    // Create Time
                    CMTime dts = CMTimeMake([videoTag extendedTimestamp], 1000);
                    CMTime pts = CMTimeMake([videoTag presentationTimeStamp], 1000);
                    
                    CMSampleTimingInfo timingInfo;
                    timingInfo.decodeTimeStamp = dts;
                    timingInfo.presentationTimeStamp = pts;
                    timingInfo.duration = kCMTimeInvalid;
                    
                    // Create SampleBuffer
                    VCSampleBuffer *outputSampleBuffer = [self createSampleBufferWithBlockBuffer:blockBuffer
                                                                                      timingInfo:timingInfo
                                                                                     description:self.videoFormatDescription];
                    if (outputSampleBuffer == nil) continue;
                    
                    if (self.delegate &&
                        [self.delegate respondsToSelector:@selector(reader:didGetVideoSampleBuffer:)]) {
                        [self.delegate reader:self didGetVideoSampleBuffer:outputSampleBuffer];
                    }
                    CFRelease(blockBuffer);;
                }
                
            } else if ([nextTag isKindOfClass:[VCFLVAudioTag class]]) {
                VCFLVAudioTag *audioTag= (VCFLVAudioTag *)nextTag;
                
                if (audioTag.AACPacketType == VCFLVAudioTagAACPacketTypeSequenceHeader) {
                    // seq
                    VCAudioSpecificConfig *config = [[VCAudioSpecificConfig alloc] initWithData:audioTag.payloadData];
                    [config deserialize];
                    CMAudioFormatDescriptionRef audioFormatDesc = nil;
                    OSStatus ret = [config createAudioFormatDescription:&audioFormatDesc];
                    if (ret != noErr) {
                        break;
                    }
                    _audioFormatDescription = audioFormatDesc;
                    if (self.delegate &&
                        [self.delegate respondsToSelector:@selector(reader:didGetAudioFormatDescription:)]) {
                        [self.delegate reader:self didGetAudioFormatDescription:audioFormatDesc];
                    }
                    continue;
                } else {
                    // raw
                    // create block buffer
                    NSData *payloadData = [audioTag payloadData];
                    CMBlockBufferRef blockBuffer = [self createBlockBufferWithData:payloadData];
                    if (blockBuffer == nil) continue;
                    
                    // create time
                    CMTime audioTime = CMTimeMake(audioTag.timestamp, 1000);

                    // create samplebuffer
                    VCSampleBuffer *outputSampleBuffer = [self createAudioSampleBufferWithBlockBuffer:blockBuffer
                                                                                            audioTime:audioTime
                                                                                          description:self.audioFormatDescription];
                    if (outputSampleBuffer == nil) continue;
                    
                    if (self.delegate &&
                        [self.delegate respondsToSelector:@selector(reader:didGetAudioSampleBuffer:)]) {
                        [self.delegate reader:self didGetAudioSampleBuffer:outputSampleBuffer];
                    }
                    CFRelease(blockBuffer);
                }
                
            } else if ([nextTag isKindOfClass:[VCFLVMetaTag class]]) {
                
            }
        } while (nextTag != nil &&
                 ![[NSThread currentThread] isCancelled]);
        
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(readerDidReachEOF:)]) {
            [self.delegate readerDidReachEOF:self];
            return;
        }
    }
}

- (void)stopReading {
    [self.readThread cancel];
}

- (void)seekToTime:(CMTime)time {
    VCFLVVideoKeyFrameIndex *index = [self.keyFrameIndex indexOfTime:time];
    if (index == nil) {
        return;
    }
    _file.currentFileOffset = index.position;
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


- (VCSampleBuffer *)createAudioSampleBufferWithBlockBuffer:(CMBlockBufferRef)blockBuffer
                                                 audioTime:(CMTime)audioTime
                                               description:(CMFormatDescriptionRef)description {
    // create packet description
    AudioStreamPacketDescription packetDesc;
    packetDesc.mDataByteSize = (UInt32)CMBlockBufferGetDataLength(blockBuffer);
    packetDesc.mStartOffset = 0;
    packetDesc.mVariableFramesInPacket = 0;
    
    CMSampleBufferRef audioSampleBuffer = nil;
    OSStatus ret = CMAudioSampleBufferCreateReadyWithPacketDescriptions(kCFAllocatorDefault,
                                                                        blockBuffer,
                                                                        self.audioFormatDescription,
                                                                        1,
                                                                        audioTime,
                                                                        &packetDesc,
                                                                        &audioSampleBuffer);
    if (ret != noErr) {
        return nil;
    }
    return [[VCSampleBuffer alloc] initWithSampleBuffer:audioSampleBuffer];
}

@end

@implementation NSArray (VCFLVReaderSeek)
- (VCFLVVideoKeyFrameIndex *)indexOfTime:(CMTime)time {
    for (VCFLVVideoKeyFrameIndex *index in self) {
        if (index == nil) {
            return nil;
        }
        CMTime currentIndexPts = index.presentationTime;
        if (CMTimeCompare(currentIndexPts, time) == 1) {
            return index;
        }
    }
    return [self lastObject];
}
@end
