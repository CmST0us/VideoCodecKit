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
@property (nonatomic, assign) CMFormatDescriptionRef videoFormatDescription;
@property (nonatomic, assign) CMFormatDescriptionRef audioFormatDescription;

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

- (void)reCreateSeekTable {
    VCFLVTag *nextTag = nil;
    NSInteger fileOffset = _file.currentFileOffset;
    NSMutableArray *keyFrameIndexArray = [[NSMutableArray alloc] init];
    CMTime maxTime = CMTimeMake(0, 1000);
    do {
        nextTag = [_file nextTag];
        if (nextTag == nil) break;
        
        CMTime currentTime = CMTimeMake([nextTag extendedTimeStamp], 1000);
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
    [self reCreateSeekTable];
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
                    if (ret != noErr) {
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
                    
                    CMBlockBufferRef blockBuffer = nil;
                    NSData *blockData = [videoTag payloadData];
                    const size_t blockDataSizeArray[] = {blockData.length};
                    OSStatus ret = CMBlockBufferCreateWithMemoryBlock(kCFAllocatorDefault,
                                                                      (void *)blockData.bytes,
                                                                      blockData.length,
                                                                      kCFAllocatorNull,
                                                                      NULL,
                                                                      0,
                                                                      blockData.length,
                                                                      0,
                                                                      &blockBuffer);
                    if (ret != noErr) {
                        // skip this tag
                        continue;
                    }
                    
                    // Create Time
                    CMTime dts = CMTimeMake([videoTag extendedTimeStamp], 1000);
                    CMTime pts = CMTimeMake([videoTag presentationTimeStamp], 1000);
                    
                    CMSampleTimingInfo timingInfo;
                    timingInfo.decodeTimeStamp = dts;
                    timingInfo.presentationTimeStamp = pts;
                    timingInfo.duration = kCMTimeInvalid;
                    // Add Format Description
                    // Create SampleBuffer
                    CMSampleBufferRef sampleBuffer = nil;
                    ret = CMSampleBufferCreateReady(kCFAllocatorDefault,
                                                    blockBuffer,
                                                    self.videoFormatDescription,
                                                    1,
                                                    1,
                                                    &timingInfo,
                                                    1,
                                                    blockDataSizeArray,
                                                    &sampleBuffer);
                    if (ret != noErr) {
                        continue;
                    }
                    
                    VCSampleBuffer *outputSampleBuffer = [[VCSampleBuffer alloc] initWithSampleBuffer:sampleBuffer];
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
                    
                    CMBlockBufferRef blockBuffer = nil;
                    OSStatus ret = CMBlockBufferCreateWithMemoryBlock(kCFAllocatorDefault,
                                                                      (void *)payloadData.bytes, payloadData.length, kCFAllocatorNull, NULL, 0, payloadData.length, 0, &blockBuffer);
                    if (ret != noErr) {
                        continue;
                    }
                    // create packet description
                    AudioStreamPacketDescription packetDesc;
                    packetDesc.mDataByteSize = (UInt32)payloadData.length;
                    packetDesc.mStartOffset = 0;
                    packetDesc.mVariableFramesInPacket = 0;
                    
                    // create time
                    CMTime audioTime = CMTimeMake(audioTag.timestamp, 1000);
                    
                    // create samplebuffer
                    CMSampleBufferRef audioSampleBuffer = nil;
                    ret = CMAudioSampleBufferCreateReadyWithPacketDescriptions(kCFAllocatorDefault,
                                                                               blockBuffer,
                                                                               self.audioFormatDescription,
                                                                               1,
                                                                               audioTime,
                                                                               &packetDesc,
                                                                               &audioSampleBuffer);
                    if (ret != noErr) {
                        continue;
                    }
                    
                    VCSampleBuffer *outputSampleBuffer = [[VCSampleBuffer alloc] initWithSampleBuffer:audioSampleBuffer];
                    
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

        // [TODO]:
//        if (self.delegate &&
//            [self.delegate respondsToSelector:@selector(readerDidReachEOF:)]) {
//            [self.delegate readerDidReachEOF:self];
//            return;
//        }
    }
}

- (void)seekToTime:(CMTime)time {
    VCFLVVideoKeyFrameIndex *index = [self.keyFrameIndex indexOfTime:time];
    if (index == nil) {
        return;
    }
    _file.currentFileOffset = index.position;
}

- (void)dealloc {
    if (_videoFormatDescription) {
        CFRelease(_videoFormatDescription);
        _videoFormatDescription = NULL;
    }
    if (_audioFormatDescription) {
        CFRelease(_audioFormatDescription);
        _audioFormatDescription = NULL;
    }
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
