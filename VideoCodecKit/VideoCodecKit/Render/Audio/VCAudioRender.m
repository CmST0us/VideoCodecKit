//
//  VCAudioRender.m
//  VideoCodecKit
//
//  Created by CmST0us on 2018/11/8.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "VCAudioRender.h"
#import "VCAudioFrame.h"
#import "VCSafeObjectQueue.h"

#define kVCAudioRenderBufferSize 3

@interface VCAudioRender () {
    AudioQueueBufferRef _audioBuffer[kVCAudioRenderBufferSize];
}
//@property (nonatomic, assign) UInt32 bufferByteSize;
//@property (nonatomic, assign) SInt64 currentPacket;
//@property (nonatomic, assign) UInt32 numPacketsToRead;
@property (nonatomic, assign) NSUInteger frameReadedSize;
@property (nonatomic, assign) AudioStreamPacketDescription packetDescription;
@property (nonatomic, assign) AudioQueueRef audioQueue;
@property (nonatomic, strong) VCSafeObjectQueue *queue;
@end

@implementation VCAudioRender

#pragma mark - AudioQueue Callback
void audioQueueOutputCallback(void * __nullable   inUserData,
                              AudioQueueRef       inAQ,
                              AudioQueueBufferRef inBuffer) {
    VCAudioRender *render = (__bridge VCAudioRender *)(inUserData);
    AudioStreamPacketDescription desc = {0};
    VCAudioFrame *frame = (VCAudioFrame *)[render.queue fetch];
    if (frame != nil) {
        if (inBuffer->mAudioDataBytesCapacity > frame.parseSize) {
            inBuffer->mAudioDataByteSize = (UInt32)frame.parseSize;
            memcpy(inBuffer->mAudioData, frame.parseData, frame.parseSize);
            [render.queue pull];
        } else {
            NSInteger frameSize = frame.parseSize;
            NSInteger restSize = frameSize - render.frameReadedSize;
            if (restSize < inBuffer->mAudioDataBytesCapacity) {
                memcpy(inBuffer->mAudioData, frame.parseData + render.frameReadedSize, restSize);
                render.frameReadedSize = 0;
            } else {
                memcpy(inBuffer->mAudioData, frame.parseData + render.frameReadedSize, inBuffer->mAudioDataBytesCapacity);
                render.frameReadedSize += inBuffer->mAudioDataBytesCapacity;
            }
        }
        desc = frame.packetDescription;
    }
    OSStatus ret= AudioQueueEnqueueBuffer(inAQ, inBuffer, 1, &desc);
    if (ret != noErr) {
        NSLog(@"[RENDER][AUDIO]: can not enqueue buffer");
    }
}

#pragma mark - Private Method
- (NSInteger)preferAudioBufferSize {
    return 360;
    static const int maxBufferSize = 0x10000;
    static const int minBufferSize = 0x4000;
    UInt32 outBufferSize = 0;
//    if (_basicDescription.mFramesPerPacket != 0) {
//        // [TODO] magic number 0.5
//        Float64 numPacketsForTime = _basicDescription.mSampleRate / _basicDescription.mFramesPerPacket * 0.5;
//        outBufferSize = numPacketsForTime * maxPacketSize;
//    } else {
//        outBufferSize = maxBufferSize > maxPacketSize ? maxBufferSize : maxPacketSize;
//    }
//    if (outBufferSize > maxBufferSize && outBufferSize > maxPacketSize){
//        outBufferSize = maxBufferSize;
//    }
//    else {
//        if (outBufferSize < minBufferSize){
//            outBufferSize = minBufferSize;
//        }
//    }
    return minBufferSize;
//    *outNumPacketsToRead = *outBufferSize / maxPacketSize;
}

#pragma mark - Public Method
- (instancetype)init {
    AudioStreamBasicDescription desc = {0};
    return [self initWithAudioStreamBasicDescription:desc];
}

- (instancetype)initWithAudioStreamBasicDescription:(AudioStreamBasicDescription)description {
    self = [super init];
    if (self) {
        _queue = [[VCSafeObjectQueue alloc] initWithSize:kVCAudioRenderBufferSize];
        _frameReadedSize = 0;
        _basicDescription = description;
        OSStatus ret = AudioQueueNewOutput(&description, audioQueueOutputCallback, (__bridge void * _Nullable)(self), NULL, NULL, 0, &_audioQueue);
        if (ret != noErr) {
            NSLog(@"[RENDER][AUDIO]: can not init audio output");
            return nil;
        }
        for (int i = 0; i < kVCAudioRenderBufferSize; ++i) {
            ret = AudioQueueAllocateBuffer(_audioQueue, (UInt32)[self preferAudioBufferSize], _audioBuffer + i);
            if (ret != noErr) {
                NSLog(@"[RENDER][AUDIO]: can not init buffer");
                return nil;
            }
            _audioBuffer[i]->mAudioDataByteSize = (UInt32)[self preferAudioBufferSize];
            ret = AudioQueueEnqueueBuffer(_audioQueue, _audioBuffer[i], 0, NULL);
            if (ret != noErr) {
                NSLog(@"[RENDER][AUDIO]: can not enqueu audio buffer");
                return nil;
            }
        }
        ret = AudioQueueStart(_audioQueue, NULL);
        if (ret != noErr) {
            NSLog(@"[RENDER][AUDIO]: can not start audio queue");
            return nil;
        }
    }
    return self;
}

- (void)dealloc {
    [self stop];
    if (_audioQueue != NULL) {
        AudioQueueDispose(_audioQueue, YES);
        _audioQueue = NULL;
    }
}

- (void)play {
    if (_audioQueue != NULL) {
        AudioQueueStart(_audioQueue, NULL);
    }
}

- (void)stop {
    if (_audioQueue != NULL) {
        AudioQueueReset(_audioQueue);
    }
    [_queue clear];
}

#pragma mark - Override Method
- (NSArray<NSString *> *)supportRenderClassName {
    return @[
             NSStringFromClass([VCAudioFrame class]),
             ];
}

- (void)render:(id)object {
    if (object == nil) return;
    NSArray *supportImages = [self supportRenderClassName];
    BOOL isSupportRenderImage = NO;
    for (NSString *imageName in supportImages) {
        if ([NSStringFromClass([object class]) isEqualToString:imageName]) {
            isSupportRenderImage = YES;
        }
    }
    if (!isSupportRenderImage) {
        return;
    }
    
    VCAudioFrame *frame = (VCAudioFrame *)object;
    [self.queue push:frame];
//    AudioQueueBufferRef buffer;
//    OSStatus ret = AudioQueueAllocateBuffer(self.audioQueue, (UInt32)frame.parseSize, &buffer);
//    if (ret != noErr) {
//#if DEBUG
//        NSLog(@"[RENDER][AUDIO]: can not allocate buffer;");
//#endif
//        return;
//    }
//    buffer->mAudioDataByteSize = (UInt32)frame.parseSize;
//
//    AudioStreamPacketDescription desc = frame.packetDescription;
//    desc.mStartOffset = 0;
//    ret = AudioQueueEnqueueBuffer(self.audioQueue, buffer, 1, &desc);
//    if (ret != noErr) {
//#if DEBUG
//        NSLog(@"[RENDER][AUDIO]: can not enqueue buffer;");
//#endif
//        return;
//    }
}

@end
