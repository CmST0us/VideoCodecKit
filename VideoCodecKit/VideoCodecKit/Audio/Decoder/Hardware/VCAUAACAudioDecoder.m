//
//  VCAUAACAudioDecoder.m
//  VideoCodecKit
//
//  Created by CmST0us on 2018/11/6.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import <pthread.h>
#import <AudioUnit/AudioUnit.h>
#import <AVFoundation/AVFoundation.h>
#import "VCAUAACAudioDecoder.h"
#import "VCAACFrame.h"
#import "VCSafeObjectQueue.h"

#define kVCAUAACAudioDecoderQueueSize 100

#define OUTPUT_BUS  0
#define INPUT_BUS   1

#define DECODER_LOCK pthread_mutex_lock(&_decoderLock)
#define DECODER_UNLOCK pthread_mutex_unlock(&_decoderLock)

@interface VCAUAACAudioDecoder () {
    pthread_mutex_t _decoderLock;
}
@property (nonatomic, assign) AudioUnit audioUnit;
@property (nonatomic, strong) VCSafeObjectQueue *audioFrameList;
@property (nonatomic, assign) size_t readSize;
@end

@implementation VCAUAACAudioDecoder

static OSStatus audioPlayCallback(void *inRefCon,
                             AudioUnitRenderActionFlags *ioActionFlags,
                             const AudioTimeStamp *inTimeStamp,
                             UInt32 inBusNumber,
                             UInt32 inNumberFrames,
                             AudioBufferList *ioData) {
    VCAUAACAudioDecoder *decoder = (__bridge VCAUAACAudioDecoder *)inRefCon;
    if (decoder.audioFrameList.count == 0) {
        return noErr;
    }
    
    VCAACFrame *firstFrame = (VCAACFrame *)[decoder.audioFrameList fetch];
    
    if (decoder.readSize + ioData->mBuffers[0].mDataByteSize > firstFrame.parseSize) {
        decoder.readSize = 0;
    }
    for (int i = 0; i < MIN(ioData->mNumberBuffers, decoder.audioFrameList.count); ++i) {
        VCAACFrame *aacFrame = (VCAACFrame *)[decoder.audioFrameList fetch];
        if (aacFrame == nil) {
            continue;
        }
        memcpy(ioData->mBuffers[i].mData, aacFrame.parseData + decoder.readSize, ioData->mBuffers[i].mDataByteSize);
        decoder.readSize += ioData->mBuffers[i].mDataByteSize;
    }
    return noErr;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        pthread_mutex_init(&_decoderLock, NULL);
        _audioFrameList = [[VCSafeObjectQueue alloc] initWithSize:kVCAUAACAudioDecoderQueueSize threadSafe:YES];
        _readSize = 0;
    }
    return self;
}

- (instancetype)initWithConfig:(VCAUAACAudioDecoderConfig *)config {
    self = [self init];
    if (self) {
        _config = config;
    }
    return self;
}
- (void)dealloc {
    [self invalidate];
    pthread_mutex_destroy(&_decoderLock);
}

#pragma mark - Override Method
- (BOOL)setup {
    if (![super setup]) {
        DECODER_LOCK;
        [self rollbackStateTransition];
        DECODER_UNLOCK;
        return NO;
    }
    DECODER_LOCK;
    NSError *err = nil;
    OSStatus ret = noErr;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:&err];
    [audioSession setPreferredIOBufferDuration:0.1 error:&err];
    
    AudioComponentDescription audioDesc;
    audioDesc.componentType = kAudioUnitType_Output;
    audioDesc.componentSubType = kAudioUnitSubType_RemoteIO;
    audioDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
    audioDesc.componentFlags = 0;
    audioDesc.componentFlagsMask = 0;
    
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &audioDesc);
    AudioComponentInstanceNew(inputComponent, &_audioUnit);
    
    UInt32 flag = 1;
    if (flag) {
        ret = AudioUnitSetProperty(_audioUnit,
                                   kAudioOutputUnitProperty_EnableIO,
                                   kAudioUnitScope_Output,
                                   OUTPUT_BUS,
                                   &flag,
                                   sizeof(flag));
    }
    if (ret) {
#if DEBUG
        NSLog(@"[DECODER][AU]: can not set property");
#endif
        [self rollbackStateTransition];
        DECODER_UNLOCK;
        return NO;
    }
    
    AURenderCallbackStruct playCallback;
    playCallback.inputProc = audioPlayCallback;
    playCallback.inputProcRefCon = (__bridge void * _Nullable)(self);
    AudioUnitSetProperty(_audioUnit,
                         kAudioUnitProperty_SetRenderCallback,
                         kAudioUnitScope_Input,
                         OUTPUT_BUS,
                         &playCallback,
                         sizeof(playCallback));
    ret = AudioUnitInitialize(_audioUnit);
    if (ret != noErr) {
#if DEBUG
        NSLog(@"[DECODER][AU]: can not init");
#endif
        [self rollbackStateTransition];
        DECODER_UNLOCK;
        return NO;
    }
    
    [self commitStateTransition];
    DECODER_UNLOCK;
    return YES;
}

- (BOOL)invalidate {
    if (![super invalidate]) {
        DECODER_LOCK;
        [self rollbackStateTransition];
        DECODER_UNLOCK;
        return NO;
    }
    DECODER_LOCK;
    [_audioFrameList clear];
    AudioOutputUnitStop(_audioUnit);
    AudioUnitUninitialize(_audioUnit);
    AudioComponentInstanceDispose(_audioUnit);
    DECODER_UNLOCK;
    [self commitStateTransition];
    return YES;
}

- (BOOL)run {
    if (![super run]) {
        DECODER_LOCK;
        [self rollbackStateTransition];
        DECODER_UNLOCK;
        return NO;
    }
    DECODER_LOCK;
    AudioOutputUnitStart(_audioUnit);
    [self commitStateTransition];
    DECODER_UNLOCK;
    return YES;
}

- (void)decodeWithFrame:(VCBaseFrame *)frame {
    if (frame == nil || ![[frame class] isSubclassOfClass:[VCAACFrame class]]) {
        return;
    }
    if (![self.currentState isEqualToInteger:VCBaseCodecStateRunning]) {
        return;
    }
    VCAACFrame *aacFrame = (VCBaseFrame *)frame;
    [self.audioFrameList push:aacFrame];
}

@end
