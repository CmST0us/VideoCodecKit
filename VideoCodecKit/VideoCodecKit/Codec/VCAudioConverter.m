//
//  VCAudioConverter.m
//  VideoCodecKit
//
//  Created by CmST0us on 2019/2/6.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "VCAudioConverter.h"
#import "VCAudioSpecificConfig.h"

@interface VCAudioConverter ()
@property (nonatomic, assign) AudioConverterRef converter;
@property (nonatomic, strong) dispatch_queue_t delegateQueue;

@property (nonatomic, assign) AudioBufferList *currentBufferList;
@property (nonatomic, assign) AudioBufferList *feedBufferList;

@property (nonatomic, assign) AudioStreamPacketDescription currentAudioStreamPacketDescription;

@property (nonatomic, readonly) NSUInteger outputMaxBufferSize;
@property (nonatomic, readonly) NSUInteger ioOutputDataPacketSize;
@property (nonatomic, readonly) NSUInteger outputAudioBufferCount;
@property (nonatomic, readonly) NSUInteger outputNumberChannels;
@end

@implementation VCAudioConverter

static OSStatus audioConverterInputDataProc(AudioConverterRef inAudioConverter,
                                            UInt32 *          ioNumberDataPackets,
                                            AudioBufferList * ioData,
                                            AudioStreamPacketDescription * __nullable * __nullable outDataPacketDescription,
                                            void * __nullable inUserData) {
    VCAudioConverter *converter = (__bridge VCAudioConverter *)inUserData;
    return [converter converterInputDataProcWithConverter:inAudioConverter ioNumberDataPackets:ioNumberDataPackets ioData:ioData outDataPacketDescription:outDataPacketDescription];
}

- (OSStatus)converterInputDataProcWithConverter:(AudioConverterRef)inAudioConverter
                            ioNumberDataPackets:(UInt32 *)ioNumberDataPackets
                                         ioData:(AudioBufferList *)ioData
                       outDataPacketDescription:(AudioStreamPacketDescription **)outDataPacketDescription {
    memcpy(ioData, _currentBufferList, [self audioBufferListSizeWithBufferCount:ioData->mNumberBuffers]);
    if (_currentBufferList->mBuffers[0].mDataByteSize < *ioNumberDataPackets) {
        *ioNumberDataPackets = 0;
        return noErr;
    }
    // !!! if decode aac, must set outDataPacketDescription
    if (outDataPacketDescription != NULL) {
        _currentAudioStreamPacketDescription.mStartOffset = 0;
        _currentAudioStreamPacketDescription.mDataByteSize = _currentBufferList->mBuffers[0].mDataByteSize;
        _currentAudioStreamPacketDescription.mVariableFramesInPacket = 0;
        *outDataPacketDescription = &_currentAudioStreamPacketDescription;
    }
    *ioNumberDataPackets = 1;
    return noErr;
}

- (instancetype)initWithOutputFormat:(AVAudioFormat *)outputFormat
                        sourceFormat:(AVAudioFormat *)sourceFormat
                       delegateQueue:(nonnull dispatch_queue_t)queue{
    self = [super init];
    if (self) {
        _outputFormat = outputFormat;
        _sourceFormat = sourceFormat;
        _delegateQueue = queue;
        
        _converter = nil;
        NSUInteger bufferListSize = [self audioBufferListSizeWithBufferCount:6];
        _currentBufferList = malloc(bufferListSize);
        _feedBufferList = malloc(bufferListSize);
        
        bzero(_currentBufferList, bufferListSize);
        bzero(_feedBufferList, bufferListSize);
    }
    return self;
}

- (instancetype)init {
    return [self initWithOutputFormat:[VCAudioConverter defaultAACFormat] sourceFormat:[VCAudioConverter defaultPCMFormat] delegateQueue:dispatch_get_global_queue(0, 0)];
}

- (void)dealloc {
    if (_converter != NULL) {
        AudioConverterReset(_converter);
        AudioConverterDispose(_converter);
        _converter = NULL;
    }
    
    if (_currentBufferList != NULL) {
        free(_currentBufferList);
        _currentBufferList = NULL;
    }
}

- (AudioConverterRef)converter {
    if (_converter != NULL) {
        return _converter;
    }
    const AudioStreamBasicDescription *sourceDesc = self.sourceFormat.streamDescription;
    const AudioStreamBasicDescription *outputDesc = self.outputFormat.streamDescription;
    
#if TARGET_IPHONE_SIMULATOR
    OSStatus ret = AudioConverterNew(sourceDesc, outputDesc, &_converter);
#else
    AudioClassDescription hardwareClassDesc = [self converterClassDescriptionWithManufacturer:kAppleHardwareAudioCodecManufacturer];
    AudioClassDescription softwareClassDesc = [self converterClassDescriptionWithManufacturer:kAppleSoftwareAudioCodecManufacturer];

    AudioClassDescription classDescs[] = {hardwareClassDesc, softwareClassDesc};
    OSStatus ret = AudioConverterNewSpecific(sourceDesc, outputDesc, sizeof(classDescs), classDescs, &_converter);
#endif
    if (ret != noErr) {
        return nil;
    }
    return _converter;
}

- (AudioClassDescription)converterClassDescriptionWithManufacturer:(OSType)manufacturer {
    AudioClassDescription desc;
    if (self.sourceFormat.streamDescription->mFormatID == kAudioFormatLinearPCM) {
        // Encoder
        desc.mType = kAudioEncoderComponentType;
        desc.mSubType = self.outputFormat.streamDescription->mFormatID;
    } else {
        // Decoder
        desc.mType = kAudioDecoderComponentType;
        desc.mSubType = self.sourceFormat.streamDescription->mFormatID;
    }
    desc.mManufacturer = manufacturer;
    return desc;
}

- (void)setOutputFormat:(AVAudioFormat *)outputFormat {
    if ([_outputFormat isEqual:outputFormat] ||
        outputFormat == nil) {
        return;
    }
    _outputFormat = outputFormat;
    if (_converter != nil) {
        AudioConverterDispose(_converter);
    }
    _converter = nil;
}

- (void)setSourceFormat:(AVAudioFormat *)sourceFormat {
    if ([_sourceFormat isEqual:sourceFormat] ||
        sourceFormat == nil) {
        return;
    }
    _sourceFormat = sourceFormat;
    if (_converter != nil) {
        AudioConverterDispose(_converter);
    }
    _converter = nil;
}

- (void)setBitrate:(UInt32)bitrate {
    UInt32 data = bitrate;
    AudioConverterSetProperty(self.converter,
                              kAudioConverterEncodeBitRate,
                              sizeof(data),
                              &data);
}

- (UInt32)bitrate {
    UInt32 size = sizeof(UInt32);
    UInt32 data = 0;
    AudioConverterGetProperty(self.converter,
                              kAudioConverterEncodeBitRate,
                              &size, &data);
    return data;
}

- (void)setAudioConverterQuality:(UInt32)quality {
    UInt32 data = quality;
    AudioConverterSetProperty(self.converter, kAudioConverterCodecQuality, sizeof(UInt32), &data);
}

- (UInt32)audioConverterQuality {
    UInt32 size = sizeof(UInt32);
    UInt32 data = 0;
    AudioConverterGetProperty(self.converter,
                              kAudioConverterCodecQuality,
                              &size, &data);
    return data;
}

- (VCAudioSpecificConfig *)outputAudioSpecificConfig {
    const AudioStreamBasicDescription *outputDesc = self.outputFormat.streamDescription;
    
    VCAudioSpecificConfig *config = [[VCAudioSpecificConfig alloc] init];
    config.channels = outputDesc->mChannelsPerFrame;
    config.frameLengthFlag = NO;
    config.objectType = outputDesc->mFormatFlags;
    config.sampleRate = outputDesc->mSampleRate;
    config.isDependOnCoreCoder = NO;
    config.isExtension = NO;
    return config;
}

- (NSUInteger)outputAudioBufferCount {
    if (self.outputFormat.streamDescription->mFormatID == kAudioFormatLinearPCM) {
        // Decoder
        return self.outputFormat.channelCount;
    } else {
        return 1;
    }
}

- (NSUInteger)outputMaxBufferSize {
    return 1024 * self.sourceFormat.streamDescription->mBytesPerFrame;
}
- (NSUInteger)outputNumberChannels {
    if (self.outputFormat.streamDescription->mFormatID == kAudioFormatLinearPCM) {
        return 1;
    } else {
        return self.outputFormat.channelCount;
    }
}
- (NSUInteger)ioOutputDataPacketSize {
    if (self.outputFormat.streamDescription->mFormatID == kAudioFormatLinearPCM) {
        return 1024;
    } else {
        return 1;
    }
}

- (NSUInteger)audioBufferListSizeWithBufferCount:(NSUInteger)bufferCount {
    return sizeof(AudioBufferList) + (bufferCount - 1) * sizeof(AudioBuffer);
}

- (AVAudioBuffer *)createOutputAudioBufferWithAudioBufferList:(AudioBufferList *)audioBufferList
                                               dataPacketSize:(NSUInteger)dataPacketSize {
    if (self.outputFormat.streamDescription->mFormatID == kAudioFormatLinearPCM) {
        AVAudioPCMBuffer *pcmBuffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:self.outputFormat frameCapacity:(AVAudioFrameCount)self.outputMaxBufferSize];
        for (int i = 0; i < audioBufferList->mNumberBuffers; ++i) {
            // 注意这个ioOutoutDataPacketSize 是转换后实际有效PCM音频大小
            // 可以将outputBufferList每个buffer大小修改为1024，可以发现转换后的ioOutputDataPacketSize变了；
            memcpy(pcmBuffer.floatChannelData[i], audioBufferList->mBuffers[i].mData, audioBufferList->mBuffers[i].mDataByteSize);
        }
        // frameLength 为有效PCM数据
        pcmBuffer.frameLength = (AVAudioFrameCount)dataPacketSize;
        return pcmBuffer;
    }
    
    NSUInteger audioBufferListSize = 0;
    for (int i = 0; i < audioBufferList->mNumberBuffers; ++i) {
        audioBufferListSize += audioBufferList->mBuffers[i].mDataByteSize;
    }
    AVAudioCompressedBuffer *compressedBuffer = [[AVAudioCompressedBuffer alloc] initWithFormat:self.outputFormat packetCapacity:audioBufferList->mNumberBuffers maximumPacketSize:audioBufferListSize];
    for (int i = 0; i < compressedBuffer.audioBufferList->mNumberBuffers; ++i) {
        memcpy(compressedBuffer.audioBufferList->mBuffers[i].mData, audioBufferList->mBuffers[i].mData, audioBufferList->mBuffers[i].mDataByteSize);
    }
    compressedBuffer.packetCount = (AVAudioPacketCount)compressedBuffer.audioBufferList->mNumberBuffers;
    compressedBuffer.byteLength = (UInt32)audioBufferListSize;
    return compressedBuffer;
}

- (OSStatus)convertAudioBufferList:(AudioBufferList *)audioBufferList
             presentationTimeStamp:(CMTime)pts {
    /// 先判断是解码还是编码
    if (self.outputFormat.streamDescription->mFormatID == kAudioFormatLinearPCM) {
        /// 解码
        return [self decodeAudioBufferList:audioBufferList presentationTimeStamp:pts];
    } else if (self.outputFormat.streamDescription->mFormatID == kAudioFormatMPEG4AAC) {
        /// 编码
        return [self encodeAudioBufferList:audioBufferList presentationTimeStamp:pts];
    }
    
    return -1;
}

- (OSStatus)encodeAudioBufferList:(AudioBufferList *)audioBufferList
            presentationTimeStamp:(CMTime)pts {
    /// 1. 判断输入的Buffer是否大于一个包的大小，如果大于，需要分包，如果小于，直接送Encoder
    self.feedBufferList->mNumberBuffers = audioBufferList->mNumberBuffers;
    for (int i = 0; i < self.feedBufferList->mNumberBuffers; ++i) {
        self.feedBufferList->mBuffers[i].mNumberChannels = audioBufferList->mBuffers[i].mNumberChannels;
        if (self.feedBufferList->mBuffers[i].mDataByteSize > 0) {
            /// data copy
            NSInteger dataSize = self.feedBufferList->mBuffers[i].mDataByteSize + audioBufferList->mBuffers[i].mDataByteSize;
            uint8_t *newBuffer = (uint8_t *)malloc(dataSize);
            memcpy(newBuffer, self.feedBufferList->mBuffers[i].mData, self.feedBufferList->mBuffers[i].mDataByteSize);
            memcpy(newBuffer + self.feedBufferList->mBuffers[i].mDataByteSize, audioBufferList->mBuffers[i].mData, audioBufferList->mBuffers[i].mDataByteSize);
            
            free(self.feedBufferList->mBuffers[i].mData);
            self.feedBufferList->mBuffers[i].mData = newBuffer;
            self.feedBufferList->mBuffers[i].mDataByteSize = (UInt32)dataSize;
            self.feedBufferList->mBuffers[i].mNumberChannels = audioBufferList->mBuffers[i].mNumberChannels;
        } else {
            NSInteger dataSize = audioBufferList->mBuffers[i].mDataByteSize;
            uint8_t *newBuffer = (uint8_t *)malloc(dataSize);
            memcpy(newBuffer, audioBufferList->mBuffers[i].mData, dataSize);
            
            self.feedBufferList->mBuffers[i].mData = newBuffer;
            self.feedBufferList->mBuffers[i].mDataByteSize = (UInt32)dataSize;
            self.feedBufferList->mBuffers[i].mNumberChannels = audioBufferList->mBuffers[i].mNumberChannels;
        }
    }
    
    /// 2. 分包调用
    UInt32 outputMaxBufferSize = (UInt32)self.outputMaxBufferSize;
    UInt32 ioOutputDataPacketSize = (UInt32)self.ioOutputDataPacketSize;
    
    NSInteger splitCount = self.feedBufferList->mBuffers[0].mDataByteSize / outputMaxBufferSize;
    NSInteger restSize = self.feedBufferList->mBuffers[0].mDataByteSize % outputMaxBufferSize;
    
    /// splitCount 为循环次数
    for (int i = 0; i < splitCount; ++i) {
        AudioBufferList *outputBufferList = (AudioBufferList *)malloc([self audioBufferListSizeWithBufferCount:self.outputFormat.channelCount]);
        _currentBufferList->mNumberBuffers = self.feedBufferList->mNumberBuffers;
        outputBufferList->mNumberBuffers = (UInt32)self.outputAudioBufferCount;
        for (int j = 0; j < self.feedBufferList->mNumberBuffers; ++j) {
            
            _currentBufferList->mBuffers[j].mData = malloc(outputMaxBufferSize);
            uint8_t *p = self.feedBufferList->mBuffers[j].mData;
            memcpy(_currentBufferList->mBuffers[j].mData, p + i * outputMaxBufferSize, outputMaxBufferSize);
            _currentBufferList->mBuffers[j].mNumberChannels = self.feedBufferList->mBuffers[j].mNumberChannels;
            _currentBufferList->mBuffers[j].mDataByteSize = outputMaxBufferSize;
            
            outputBufferList->mBuffers[j].mNumberChannels = (UInt32)self.outputNumberChannels;
            outputBufferList->mBuffers[j].mDataByteSize = outputMaxBufferSize;
            outputBufferList->mBuffers[j].mData = malloc(outputMaxBufferSize);
        }
        
        OSStatus ret = AudioConverterFillComplexBuffer(self.converter,
                                                       audioConverterInputDataProc,
                                                       (__bridge void *)self,
                                                       &ioOutputDataPacketSize,
                                                       outputBufferList,
                                                       NULL);
        
        for (int j = 0; j < _currentBufferList->mNumberBuffers; ++j) {
            free(_currentBufferList->mBuffers[j].mData);
        }
        
        if (ret != noErr) {
            return ret;
        }

        
        AVAudioBuffer *audioBuffer = [self createOutputAudioBufferWithAudioBufferList:outputBufferList dataPacketSize:ioOutputDataPacketSize];
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(converter:didOutputAudioBuffer:presentationTimeStamp:)]) {
            dispatch_async(self.delegateQueue, ^{
                [self.delegate converter:self didOutputAudioBuffer:audioBuffer presentationTimeStamp:pts];
            });
        }
    
        for (int j = 0; j < self.outputAudioBufferCount; ++j) {
            free(outputBufferList->mBuffers[j].mData);
        }
        free(outputBufferList);
    }
    
    for (int i = 0; i < self.feedBufferList->mNumberBuffers; ++i) {
        if (restSize == 0) {
            free(self.feedBufferList->mBuffers[i].mData);
            self.feedBufferList->mBuffers[i].mData = NULL;
            self.feedBufferList->mBuffers[i].mDataByteSize = 0;
        } else {
            uint8_t *p = (uint8_t *)self.feedBufferList->mBuffers[i].mData;
            memcpy(self.feedBufferList->mBuffers[i].mData, p + splitCount * outputMaxBufferSize, restSize);
            self.feedBufferList->mBuffers[i].mDataByteSize = (UInt32)restSize;
        }
    }
    
    return noErr;
}

- (OSStatus)decodeAudioBufferList:(AudioBufferList *)audioBufferList
            presentationTimeStamp:(CMTime)pts {
    /// 2. 分包调用
    UInt32 outputMaxBufferSize = (UInt32)self.outputMaxBufferSize;
    UInt32 ioOutputDataPacketSize = (UInt32)self.ioOutputDataPacketSize;
    
    /// splitCount 为循环次数
    _currentBufferList->mNumberBuffers = self.feedBufferList->mNumberBuffers;
    for (int i = 0; i < audioBufferList->mNumberBuffers; ++i) {
        _currentBufferList->mBuffers[i].mData = malloc(ioOutputDataPacketSize);
        memcpy(_currentBufferList->mBuffers[i].mData, audioBufferList->mBuffers[i].mData, audioBufferList->mBuffers[i].mDataByteSize);
        _currentBufferList->mBuffers[i].mNumberChannels = audioBufferList->mBuffers[i].mNumberChannels;
        _currentBufferList->mBuffers[i].mDataByteSize = audioBufferList->mBuffers[i].mDataByteSize;
    }
    
    AudioBufferList *outputBufferList = (AudioBufferList *)malloc([self audioBufferListSizeWithBufferCount:self.outputFormat.channelCount]);
    outputBufferList->mNumberBuffers = (UInt32)self.outputAudioBufferCount;
    for (int i = 0; i < self.outputAudioBufferCount; ++i) {
        outputBufferList->mBuffers[i].mNumberChannels = (UInt32)self.outputNumberChannels;
        outputBufferList->mBuffers[i].mDataByteSize = outputMaxBufferSize;
        outputBufferList->mBuffers[i].mData = malloc(outputMaxBufferSize);
    }
    
    OSStatus ret = AudioConverterFillComplexBuffer(self.converter,
                                                   audioConverterInputDataProc,
                                                   (__bridge void *)self,
                                                   &ioOutputDataPacketSize,
                                                   outputBufferList,
                                                   NULL);
    for (int i = 0; i < _currentBufferList->mNumberBuffers; ++i) {
        free(_currentBufferList->mBuffers[i].mData);
    }
    
    if (ret != noErr) {
        return ret;
    }
    
    AVAudioBuffer *audioBuffer = [self createOutputAudioBufferWithAudioBufferList:outputBufferList dataPacketSize:ioOutputDataPacketSize];
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(converter:didOutputAudioBuffer:presentationTimeStamp:)]) {
        dispatch_async(self.delegateQueue, ^{
            [self.delegate converter:self didOutputAudioBuffer:audioBuffer presentationTimeStamp:pts];
        });
    }
    
    for (int i = 0; i < self.outputAudioBufferCount; ++i) {
        free(outputBufferList->mBuffers[i].mData);
    }
    free(outputBufferList);
    return noErr;
}

- (OSStatus)convertSampleBuffer:(VCSampleBuffer *)sampleBuffer {
    if (self.converter == nil) return -1;
    size_t size = [self audioBufferListSizeWithBufferCount:self.sourceFormat.channelCount];
    AudioBufferList *bufferList = malloc(size);
    memset(bufferList, 0, size);
    CMBlockBufferRef blockBuffer = NULL;
    OSStatus ret = CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer.sampleBuffer,
                                                                           NULL,
                                                                           bufferList,
                                                                           sizeof(AudioBufferList),
                                                                           kCFAllocatorDefault,
                                                                           kCFAllocatorDefault,
                                                                           0,
                                                                           &blockBuffer);
    
    if (ret != noErr) {
        return ret;
    }
    
    ret = [self convertAudioBufferList:bufferList presentationTimeStamp:sampleBuffer.presentationTimeStamp];
    
    if (blockBuffer != NULL) {
        CFRelease(blockBuffer);
        blockBuffer = NULL;
    }
    
    free(bufferList);
    
    return ret;
}

- (void)reset {
    AudioConverterReset(self.converter);
}

+ (AVAudioFormat *)AACFormatWithSampleRate:(Float64)sampleRate channels:(UInt32)channels {
    return [VCAudioConverter AACFormatWithSampleRate:sampleRate
                                         formatFlags:kMPEG4Object_AAC_LC
                                            channels:channels];
}

+ (AVAudioFormat *)AACFormatWithSampleRate:(Float64)sampleRate
                               formatFlags:(AudioFormatFlags)flags
                                  channels:(UInt32)channels {
    AudioStreamBasicDescription basicDescription;
    basicDescription.mFormatID = kAudioFormatMPEG4AAC;
    basicDescription.mSampleRate = sampleRate;
    basicDescription.mFormatFlags = flags;
    basicDescription.mBytesPerFrame = 0;
    basicDescription.mFramesPerPacket = 1024;
    basicDescription.mBytesPerPacket = 0;
    basicDescription.mChannelsPerFrame = channels;
    basicDescription.mBitsPerChannel = 0;
    basicDescription.mReserved = 0;
    
    CMAudioFormatDescriptionRef outputDescription = nil;
    OSStatus ret = CMAudioFormatDescriptionCreate(kCFAllocatorDefault, &basicDescription, 0, NULL, 0, NULL, NULL, &outputDescription);
    if (ret != noErr) {
        return nil;
    }
    
    AVAudioFormat *format = [[AVAudioFormat alloc] initWithCMAudioFormatDescription:outputDescription];
    CFRelease(outputDescription);
    
    return format;
}

+ (AVAudioFormat *)formatWithCMAudioFormatDescription:(CMAudioFormatDescriptionRef)audioFormatDescription {
    AVAudioFormat *format = [[AVAudioFormat alloc] initWithCMAudioFormatDescription:audioFormatDescription];
    return format;
}

+ (AVAudioFormat *)PCMFormatWithSampleRate:(Float64)sampleRate
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

+ (AVAudioFormat *)defaultPCMFormat {
    return [VCAudioConverter PCMFormatWithSampleRate:44100 channels:2];
}

+ (AVAudioFormat *)defaultAACFormat {
    return [VCAudioConverter AACFormatWithSampleRate:44100 channels:2];
}

@end
