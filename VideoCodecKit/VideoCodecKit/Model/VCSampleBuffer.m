//
//  VCSampleBuffer.m
//  VideoCodecKit
//
//  Created by CmST0us on 2019/1/19.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "VCSampleBuffer.h"

@interface VCSampleBuffer ()
@property (nonatomic, assign) BOOL shouldFreeWhenDone;
@end

@implementation VCSampleBuffer

- (instancetype)initWithSampleBuffer:(CMSampleBufferRef)aSampleBuffer {
    return [self initWithSampleBuffer:aSampleBuffer freeWhenDone:YES];
}

- (instancetype)initWithSampleBuffer:(CMSampleBufferRef)aSampleBuffer freeWhenDone:(BOOL)shouldFreeWhenDone {
    self = [super init];
    if (self) {
        _sampleBuffer = aSampleBuffer;
        _shouldFreeWhenDone = shouldFreeWhenDone;
    }
    return self;
}

- (CMBlockBufferRef)dataBuffer {
    return CMSampleBufferGetDataBuffer(_sampleBuffer);
}

- (void)setDataBuffer:(CMBlockBufferRef)dataBuffer {
    CMSampleBufferSetDataBuffer(_sampleBuffer, dataBuffer);
}

- (CVImageBufferRef)imageBuffer {
    return CMSampleBufferGetImageBuffer(_sampleBuffer);
}

- (CMItemCount)numberOfSamples {
    return CMSampleBufferGetNumSamples(_sampleBuffer);
}

- (CMTime)duration {
    return CMSampleBufferGetDuration(_sampleBuffer);
}

- (CMFormatDescriptionRef)formatDescription {
    return CMSampleBufferGetFormatDescription(_sampleBuffer);
}

- (CMTime)decodeTimeStamp {
    return CMSampleBufferGetDecodeTimeStamp(_sampleBuffer);
}

- (CMTime)presentationTimeStamp {
    return CMSampleBufferGetPresentationTimeStamp(_sampleBuffer);
}

- (BOOL)keyFrame {
    CFArrayRef attach = CMSampleBufferGetSampleAttachmentsArray(_sampleBuffer, false);
    if (attach == NULL) {
        return YES;
    }
    CFDictionaryRef dict = CFArrayGetValueAtIndex(attach, 0);
    if (dict == NULL) {
        return YES;
    }
    BOOL keyFrame = !CFDictionaryContainsKey(dict, kCMSampleAttachmentKey_NotSync);
    return keyFrame;
}

- (AudioStreamBasicDescription)audioStreamBasicDescription {
    CMAudioFormatDescriptionRef audioFormat = CMSampleBufferGetFormatDescription(_sampleBuffer);
    return *CMAudioFormatDescriptionGetStreamBasicDescription(audioFormat);
}

- (NSData *)h264ParameterSetData {
    const uint8_t *outPtr = nil;
    size_t outSize = 0;
    uint8_t header[] = {0x00, 0x00, 0x00, 0x01};
    NSMutableData *data = [[NSMutableData alloc] init];
    OSStatus ret = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(self.formatDescription, 0, &outPtr, &outSize, NULL, NULL);
    if (ret != noErr) return nil;
    [data appendBytes:header length:4];
    [data appendBytes:outPtr length:outSize];
    
    ret = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(self.formatDescription, 1, &outPtr, &outSize, NULL, NULL);
    if (ret != noErr) return nil;
    [data appendBytes:header length:4];
    [data appendBytes:outPtr length:outSize];
    return data;
}

- (NSData *)dataBufferData {
    char *outPtr = nil;
    size_t outSize = 0;
    OSStatus ret = CMBlockBufferGetDataPointer(self.dataBuffer, 0, NULL, &outSize, &outPtr);
    if (ret != noErr) {
        return nil;
    }
    NSData *data = [[NSData alloc] initWithBytes:(void *)outPtr length:outSize];
    return data;
}

- (AVAudioFormat *)audioFormat {
    return [[AVAudioFormat alloc] initWithCMAudioFormatDescription:self.formatDescription];
}

- (AVAudioBuffer *)audioBuffer {
    size_t size = sizeof(AudioBufferList) + (self.audioFormat.channelCount - 1) * sizeof(AudioBuffer);
    if (self.audioFormat.streamDescription->mFormatID == kAudioFormatMPEG4AAC) {
        size = sizeof(AudioBufferList);
    }
    AudioBufferList *bufferList = malloc(size);
    memset(bufferList, 0, size);
    CMBlockBufferRef blockBuffer = NULL;
    OSStatus ret = CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(_sampleBuffer,
                                                                           NULL,
                                                                           bufferList,
                                                                           size,
                                                                           kCFAllocatorDefault,
                                                                           kCFAllocatorDefault,
                                                                           0,
                                                                           &blockBuffer);
    
    if (ret != noErr) {
        free(bufferList);
        return NULL;
    }
    
    AVAudioBuffer *outputBuffer = nil;
    if (self.audioFormat.streamDescription->mFormatID == kAudioFormatLinearPCM) {
        AVAudioPCMBuffer *pcmBuffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:self.audioFormat frameCapacity:(AVAudioFrameCount)1024 * self.audioFormat.streamDescription->mBytesPerFrame];
        for (int i = 0; i < bufferList->mNumberBuffers; ++i) {
            memcpy(pcmBuffer.audioBufferList->mBuffers[i].mData, bufferList->mBuffers[i].mData, bufferList->mBuffers[i].mDataByteSize);
        }
        // frameLength 为有效PCM数据
        pcmBuffer.frameLength = (AVAudioFrameCount)CMSampleBufferGetNumSamples(_sampleBuffer);
        outputBuffer = pcmBuffer;
    } else if (self.audioFormat.streamDescription->mFormatID == kAudioFormatMPEG4AAC) {
        NSUInteger audioBufferListSize = 0;
        for (int i = 0; i < bufferList->mNumberBuffers; ++i) {
            audioBufferListSize += bufferList->mBuffers[i].mDataByteSize;
        }
        AVAudioCompressedBuffer *compressedBuffer = [[AVAudioCompressedBuffer alloc] initWithFormat:self.audioFormat packetCapacity:bufferList->mNumberBuffers maximumPacketSize:audioBufferListSize];
        for (int i = 0; i < compressedBuffer.audioBufferList->mNumberBuffers; ++i) {
            memcpy(compressedBuffer.audioBufferList->mBuffers[i].mData, bufferList->mBuffers[i].mData, bufferList->mBuffers[i].mDataByteSize);
        }
        compressedBuffer.packetCount = (AVAudioPacketCount)compressedBuffer.audioBufferList->mNumberBuffers;
        compressedBuffer.byteLength = (UInt32)audioBufferListSize;
        outputBuffer = compressedBuffer;
    }
    
    if (blockBuffer != NULL) {
        CFRelease(blockBuffer);
        blockBuffer = NULL;
    }
    
    if (bufferList != NULL) {
        free(bufferList);
        bufferList = NULL;
    }
    
    return outputBuffer;
}

- (void)dealloc {
    if (_sampleBuffer &&
        _shouldFreeWhenDone) {
        CFRelease(_sampleBuffer);
        _sampleBuffer = NULL;
    }
}

@end
