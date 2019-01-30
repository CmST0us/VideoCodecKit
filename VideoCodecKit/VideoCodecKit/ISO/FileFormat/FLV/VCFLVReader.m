//
//  VCFLVReader.m
//  VideoCodecKit
//
//  Created by CmST0us on 2019/1/30.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "VCFLVReader.h"
#import "VCFLVFile.h"
#import "VCFLVTag.h"
#import "VCSampleBuffer.h"
#import "VCAVCConfigurationRecord.h"

@interface VCFLVReader ()
@property (nonatomic, strong) VCFLVFile *file;
@property (nonatomic, assign) CMFormatDescriptionRef formatDescription;
@end

@implementation VCFLVReader
- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        _file = [[VCFLVFile alloc] initWithURL:url];
        if (_file == nil) {
            return nil;
        }
    }
    return self;
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
                _formatDescription = format;
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
                if (_formatDescription == NULL) continue;
                
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
                CMTime dts = CMTimeMake(timestamp, 90000);
                
                int32_t compositionTime = (int32_t)[videoTag compositionTime];
                CMTime pts = CMTimeMake(timestamp + compositionTime, 90000);
                
                CMSampleTimingInfo timingInfo;
                timingInfo.decodeTimeStamp = dts;
                timingInfo.presentationTimeStamp = pts;
                timingInfo.duration = kCMTimeInvalid;
                // Add Format Description
                // Create SampleBuffer
                CMSampleBufferRef sampleBuffer = nil;
                ret = CMSampleBufferCreateReady(kCFAllocatorDefault,
                                                blockBuffer,
                                                self.formatDescription,
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
            
        } else if ([nextTag isKindOfClass:[VCFLVMetaTag class]]) {
            
        }
    } while (nextTag != nil);
}
- (VCSampleBuffer *)nextSampleBuffer {
    VCFLVTag *tag = [_file nextTag];
    if (tag == nil) return nil;
    
    VCSampleBuffer *sampleBuffer = [[VCSampleBuffer alloc] init];
    if ([tag isKindOfClass:[VCFLVVideoTag class]]) {
        // video tag
        
    } else if ([tag isKindOfClass:[VCFLVAudioTag class]]) {
        // audio tag
    } else {
        // unsupport tag
    }
    
    return sampleBuffer;
}

- (void)dealloc {
    CFRelease(_formatDescription);
    _formatDescription = NULL;
}
@end
