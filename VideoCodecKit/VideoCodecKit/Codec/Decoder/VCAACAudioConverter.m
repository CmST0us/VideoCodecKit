//
//  VCAACAudioConverter.m
//  VideoCodecKit
//
//  Created by CmST0us on 2019/1/31.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "VCAACAudioConverter.h"

@interface VCAACAudioConverter () {
    dispatch_queue_t _converterQueue;
}
@property (nonatomic, assign) AudioConverterRef converter;
@property (nonatomic, assign) CMFormatDescriptionRef formatDescription;

@property (nonatomic, assign) AudioBufferList currentBufferList;
@property (nonatomic, assign) CMBlockBufferRef currentAudioBlockBuffer;
@property (nonatomic, assign) AudioStreamPacketDescription currentAudioStreamPacketDescription;
@end

@implementation VCAACAudioConverter
 static OSStatus audioConverterInputDataProc(AudioConverterRef inAudioConverter,
                                             UInt32 *          ioNumberDataPackets,
                                             AudioBufferList * ioData,
                                             AudioStreamPacketDescription * __nullable * __nullable outDataPacketDescription,
                                             void * __nullable inUserData) {
     VCAACAudioConverter *converter = (__bridge VCAACAudioConverter *)inUserData;
     return [converter converterInputDataProcWithConverter:inAudioConverter ioNumberDataPackets:ioNumberDataPackets ioData:ioData outDataPacketDescription:outDataPacketDescription];
 }

- (OSStatus)converterInputDataProcWithConverter:(AudioConverterRef)inAudioConverter
                            ioNumberDataPackets:(UInt32 *)ioNumberDataPackets
                                         ioData:(AudioBufferList *)ioData
                       outDataPacketDescription:(AudioStreamPacketDescription **)outDataPacketDescription {
    memcpy(ioData, &_currentBufferList, sizeof(_currentBufferList));
    // !!! if decode aac, must set outDataPacketDescription
    if (outDataPacketDescription != NULL) {
        _currentAudioStreamPacketDescription.mStartOffset = 0;
        _currentAudioStreamPacketDescription.mDataByteSize = _currentBufferList.mBuffers[0].mDataByteSize;
        _currentAudioStreamPacketDescription.mVariableFramesInPacket = 0;
        *outDataPacketDescription = &_currentAudioStreamPacketDescription;
    }
    
    *ioNumberDataPackets = 1;
    return noErr;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        _formatDescription = NULL;
        _converterQueue = dispatch_queue_create("com.VideoCodecKit.VCAACAudioConverter.queue", DISPATCH_QUEUE_SERIAL);
        _currentAudioBlockBuffer = NULL;
    }
    return self;
}

- (void)dealloc {
    if (_converter != NULL) {
        AudioConverterReset(_converter);
        AudioConverterDispose(_converter);
        _converter = NULL;
    }
    
    if (_currentAudioBlockBuffer != NULL) {
        CFRelease(_currentAudioBlockBuffer);
        _currentAudioBlockBuffer = NULL;
    }
    
    if (_formatDescription != NULL) {
        CFRelease(_formatDescription);
        _formatDescription = NULL;
    }
}

- (AudioConverterRef)converter {
    if (_converter != nil) {
        return _converter;
    }

    const AudioStreamBasicDescription *sourceStreamBasicDesc = CMAudioFormatDescriptionGetStreamBasicDescription(self.formatDescription);
    AudioStreamBasicDescription destinationStreamBasicDesc = [VCAACAudioConverter outputFormatWithSampleRate:sourceStreamBasicDesc->mSampleRate channels:sourceStreamBasicDesc->mChannelsPerFrame];
    
    AudioClassDescription hardwareAudioClassDesc;
    hardwareAudioClassDesc.mManufacturer = kAudioDecoderComponentType;
    hardwareAudioClassDesc.mSubType = kAudioFormatMPEG4AAC;
    hardwareAudioClassDesc.mManufacturer = kAppleHardwareAudioCodecManufacturer;
    
    AudioClassDescription softwareAudioClassDesc;
    softwareAudioClassDesc.mManufacturer = kAudioDecoderComponentType;
    softwareAudioClassDesc.mSubType = kAudioFormatMPEG4AAC;
    softwareAudioClassDesc.mManufacturer = kAppleSoftwareAudioCodecManufacturer;
    
    AudioClassDescription classDescs[] = {hardwareAudioClassDesc, softwareAudioClassDesc};
    // [TODO]: Add Software Codec
    OSStatus ret = AudioConverterNewSpecific(sourceStreamBasicDesc, &destinationStreamBasicDesc, sizeof(classDescs), classDescs, &_converter);
    if (ret != noErr) {
        return nil;
    }
    return _converter;
}

- (void)setFormatDescription:(CMFormatDescriptionRef)desc {
    _formatDescription = CFRetain(desc);
}

- (UInt32)channels {
    const AudioStreamBasicDescription *desc =  CMAudioFormatDescriptionGetStreamBasicDescription(self.formatDescription);
    return desc->mChannelsPerFrame == 0 ? 1 : desc->mChannelsPerFrame;
}

- (UInt32)sampleRate {
    const AudioStreamBasicDescription *desc =  CMAudioFormatDescriptionGetStreamBasicDescription(self.formatDescription);
    return (UInt32)desc->mSampleRate;
}

- (OSStatus)convertSampleBuffer:(VCSampleBuffer *)sampleBuffer {
    if (self.formatDescription == NULL) {
        return -1;
    }
    
    UInt32 channels = [self channels];
    OSStatus ret = CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer.sampleBuffer,
                                                                           NULL,
                                                                           &_currentBufferList,
                                                                           sizeof(_currentBufferList),
                                                                           kCFAllocatorDefault,
                                                                           kCFAllocatorDefault,
                                                                           0,
                                                                           &_currentAudioBlockBuffer);
    
    if (ret != noErr) {
        return ret;
    }
    
    // get max buffer size
    UInt32 maxBufferSize = 1024 * sizeof(Float32);
    
    UInt32 ioOutputDataPacketSize = 1024;
    AudioBufferList *outputBufferList = (AudioBufferList *)malloc(sizeof(AudioBufferList) + channels * sizeof(AudioBuffer));
    outputBufferList->mNumberBuffers = channels;
    for (int i = 0; i < channels; ++i) {
        outputBufferList->mBuffers[i].mNumberChannels = i;
        outputBufferList->mBuffers[i].mDataByteSize = maxBufferSize;
        outputBufferList->mBuffers[i].mData = malloc(maxBufferSize);
    }
    
    ret = AudioConverterFillComplexBuffer(self.converter,
                                          audioConverterInputDataProc,
                                          (__bridge void *)self,
                                          &ioOutputDataPacketSize,
                                          outputBufferList,
                                          NULL);
    if (ret != noErr) {
        return ret;
    }
    
    AudioStreamBasicDescription pcmASBD = [VCAACAudioConverter outputFormatWithSampleRate:[self sampleRate] channels:[self channels]];
    AVAudioFormat *pcmFormat = [[AVAudioFormat alloc] initWithStreamDescription:&pcmASBD];
    AVAudioPCMBuffer *pcmBuffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:pcmFormat frameCapacity:maxBufferSize];
    for (int i = 0; i < outputBufferList->mNumberBuffers; ++i) {
        memcpy(pcmBuffer.floatChannelData[i], outputBufferList->mBuffers[i].mData, outputBufferList->mBuffers[i].mDataByteSize);
    }
    
    pcmBuffer.frameLength = maxBufferSize;
    
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(converter:didGetPCMBuffer:presentationTimeStamp:)]) {
        [self.delegate converter:self didGetPCMBuffer:pcmBuffer presentationTimeStamp:sampleBuffer.presentationTimeStamp];
    }
    
    for (int i = 0; i < channels; ++i) {
        free(outputBufferList->mBuffers[i].mData);
    }
    free(outputBufferList);
    
    if (_currentAudioBlockBuffer != NULL) {
        CFRelease(_currentAudioBlockBuffer);
        _currentAudioBlockBuffer = NULL;
    }
    
    return noErr;
}

- (void)reset {
    AudioConverterReset(self.converter);
}

- (AudioStreamBasicDescription)outputFormat {
    return [VCAACAudioConverter outputFormatWithSampleRate:[self sampleRate] channels:[self channels]];
}

+ (AudioStreamBasicDescription)outputFormatWithSampleRate:(Float64)sampleRate
                                     channels:(UInt32)channels {
    AudioStreamBasicDescription outputDesc;
    // reference: https://developer.apple.com/documentation/avfoundation/avaudioformat
    outputDesc.mSampleRate = sampleRate;
    outputDesc.mFormatID = kAudioFormatLinearPCM;
    // kAudioFormatFlagIsNonInterleaced must be set when output desc is multi channel.
    // kAudioFormatFlagsNativeFloatPacked should be set, if use for audio unit.
    outputDesc.mFormatFlags = kAudioFormatFlagsNativeFloatPacked |kAudioFormatFlagIsNonInterleaved;
    outputDesc.mFramesPerPacket = 1;
    outputDesc.mChannelsPerFrame = channels;
    outputDesc.mBytesPerFrame = sizeof(Float32);
    outputDesc.mBytesPerPacket = sizeof(Float32);
    outputDesc.mBitsPerChannel = 8 * sizeof(Float32);
    outputDesc.mReserved = 0;
    return outputDesc;
}
@end
