//
//  VCAACAudioConverter.m
//  VideoCodecKit
//
//  Created by CmST0us on 2019/1/31.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "VCAACAudioConverter.h"

@interface VCAACAudioConverter ()
@property (nonatomic, strong) AVAudioConverter *converter;
@property (nonatomic, assign) CMFormatDescriptionRef formatDescription;
@end

@implementation VCAACAudioConverter
- (instancetype)init {
    self = [super init];
    if (self) {
        _formatDescription = NULL;
    }
    return self;
}

- (void)dealloc {
    if (_formatDescription != NULL) {
        CFRelease(_formatDescription);
        _formatDescription = NULL;
    }
}

- (AVAudioConverter *)converter {
    if (_converter != nil) {
        return _converter;
    }
    
    if (_formatDescription == NULL) {
        return nil;
    }
    
    const AudioStreamBasicDescription *basicDesc = CMAudioFormatDescriptionGetStreamBasicDescription(self.formatDescription);
    AVAudioFormat *inFormat = [[AVAudioFormat alloc] initWithStreamDescription:basicDesc];
    _converter = [[AVAudioConverter alloc] initFromFormat:inFormat toFormat:[VCAACAudioConverter outputFormatWithSampleRate:basicDesc->mSampleRate channels:basicDesc->mChannelsPerFrame]];
    return _converter;
}

- (void)setFormatDescription:(CMFormatDescriptionRef)desc {
    _formatDescription = CFRetain(desc);
}

- (void)reset {
    [self.converter reset];
}

- (void)convertSampleBuffer:(VCSampleBuffer *)sampleBuffer {
    UInt32 channels = sampleBuffer.audioStreamBasicDescription.mChannelsPerFrame;
    UInt32 sampleRate = sampleBuffer.audioStreamBasicDescription.mSampleRate;
    
    AVAudioPCMBuffer *outputBuffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:[VCAACAudioConverter outputFormatWithSampleRate:sampleRate channels:channels] frameCapacity:1024 * channels];
    // reference: https://forums.developer.apple.com/message/189802#189802
    // reference: https://codeday.me/bug/20190103/493018.html
    outputBuffer.frameLength = 1024 * channels;
    
    NSError *error = nil;
    
    AVAudioConverterOutputStatus ret =  [self.converter convertToBuffer:outputBuffer error:&error withInputFromBlock:^AVAudioBuffer * _Nullable(AVAudioPacketCount inNumberOfPackets, AVAudioConverterInputStatus * _Nonnull outStatus) {
        char *dataPtr = nil;
        size_t len = CMBlockBufferGetDataLength(sampleBuffer.dataBuffer);
        CMBlockBufferGetDataPointer(sampleBuffer.dataBuffer, 0, NULL, NULL, &dataPtr);
        
        AudioStreamBasicDescription desc = [sampleBuffer audioStreamBasicDescription];
        AVAudioFormat *compressedAudioFormat = [[AVAudioFormat alloc] initWithStreamDescription:&desc];
        
        AVAudioCompressedBuffer *compressedBuffer =[[AVAudioCompressedBuffer alloc] initWithFormat:compressedAudioFormat packetCapacity:1 maximumPacketSize:len];
        // reference: https://forums.developer.apple.com/message/189802#189802
        // 这是一个 AVAudioBuffer 的 bug，SDK已经在iOS 11 引入的 byteLength 修复
        ((AudioBufferList *)compressedBuffer.audioBufferList)->mBuffers[0].mDataByteSize = (UInt32)len;
        memcpy(compressedBuffer.data, dataPtr, len);
        *outStatus = AVAudioConverterInputStatus_HaveData;
        return compressedBuffer;
    }];
    
    if (ret == AVAudioConverterInputStatus_EndOfStream) {
        [self reset];
    }
    
    if (error != nil) {
        NSLog(@"%@", error);
    }
}

+ (AVAudioFormat *)outputFormatWithSampleRate:(Float64)sampleRate channels:(UInt32)channels {
    AudioStreamBasicDescription outputDesc;
    outputDesc.mSampleRate = sampleRate;
    outputDesc.mFormatID = kAudioFormatLinearPCM;
    outputDesc.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsNonInterleaved;
    outputDesc.mFramesPerPacket = 1;
    outputDesc.mChannelsPerFrame = channels;
    outputDesc.mBytesPerFrame = 2;
    outputDesc.mBytesPerPacket = 2;
    outputDesc.mBitsPerChannel = 16;
    outputDesc.mReserved = 0;
    
    AVAudioFormat *outputFormat = [[AVAudioFormat alloc] initWithStreamDescription:&outputDesc];
    return outputFormat;
}
@end
