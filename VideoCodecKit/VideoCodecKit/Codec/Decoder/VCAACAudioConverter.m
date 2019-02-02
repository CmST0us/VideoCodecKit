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
    const AudioStreamBasicDescription *destinationStreamBasicDesc = [[self outputFormat] streamDescription];
    
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
    OSStatus ret = AudioConverterNewSpecific(sourceStreamBasicDesc, destinationStreamBasicDesc, sizeof(classDescs), classDescs, &_converter);
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
    
    // 如果声道数大于2 此方法返回nil
    AVAudioPCMBuffer *pcmBuffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:[self outputFormat] frameCapacity:maxBufferSize];
    for (int i = 0; i < outputBufferList->mNumberBuffers; ++i) {
        // 注意这个ioOutoutDataPacketSize 是转换后实际有效PCM音频大小
        // 可以将outputBufferList每个buffer大小修改为1024，可以发现转换后的ioOutputDataPacketSize变了；
        memcpy(pcmBuffer.floatChannelData[i], outputBufferList->mBuffers[i].mData, outputBufferList->mBuffers[i].mDataByteSize);
    }
    // frameLength 为有效PCM数据
    pcmBuffer.frameLength = ioOutputDataPacketSize;
    
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

- (AVAudioFormat *)outputFormat {
    return [VCAACAudioConverter outputFormatWithSampleRate:[self sampleRate] channels:[self channels]];
}

+ (AVAudioFormat *)outputFormatWithSampleRate:(Float64)sampleRate
                                     channels:(UInt32)channels {
    AudioChannelLayoutTag channelLayoutTag = kAudioChannelLayoutTag_Stereo;
    if (channels == 1) {
        channelLayoutTag = kAudioChannelLayoutTag_Mono;
    } else if (channels == 2) {
        channelLayoutTag = kAudioChannelLayoutTag_Stereo;
    } else if (channels == 3) {
        channelLayoutTag = kAudioChannelLayoutTag_AAC_3_0;
    } else if (channels == 4) {
        channelLayoutTag = kAudioChannelLayoutTag_AAC_4_0;
    } else if (channels == 5) {
        channelLayoutTag = kAudioChannelLayoutTag_AAC_5_0;
    } else if (channels == 6) {
        channelLayoutTag = kAudioChannelLayoutTag_AAC_5_1;
    }
    AVAudioChannelLayout *layout = [[AVAudioChannelLayout alloc] initWithLayoutTag:channelLayoutTag];
    AVAudioFormat *format = [[AVAudioFormat alloc] initWithCommonFormat:AVAudioPCMFormatFloat32 sampleRate:sampleRate interleaved:NO channelLayout:layout];
    return format;
}
@end
