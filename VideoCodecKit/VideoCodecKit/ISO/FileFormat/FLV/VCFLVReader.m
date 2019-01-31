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

@interface VCFLVReader ()
@property (nonatomic, strong) VCFLVFile *file;
@property (nonatomic, assign) CMFormatDescriptionRef videoFormatDescription;
@property (nonatomic, assign) CMFormatDescriptionRef audioFormatDescription;
@end

@implementation VCFLVReader
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

- (void)starAsyncRead {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self startRead];
    });
}

- (void)startRead {
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
                int32_t timestampExt = (int32_t)[videoTag timestampExtended];
                int32_t timestamp = (int32_t)[videoTag timestamp];
                timestamp = timestamp | (timestampExt << 24);
                CMTime dts = CMTimeMake(timestamp, 1000);
                
                int32_t compositionTime = (int32_t)[videoTag compositionTime];
                CMTime pts = CMTimeMake(timestamp + compositionTime, 1000);
                
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
    } while (nextTag != nil);
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
