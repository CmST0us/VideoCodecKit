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

#define kVCAudioRenderQueueSize 3

@interface VCAudioRender ()
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
    }
}

#pragma mark - Public Method
- (instancetype)init {
    AudioStreamBasicDescription desc = {0};
    return [self initWithAudioStreamBasicDescription:desc];
}

- (instancetype)initWithAudioStreamBasicDescription:(AudioStreamBasicDescription)description {
    self = [super init];
    if (self) {
        _queue = [[VCSafeObjectQueue alloc] initWithSize:kVCAudioRenderQueueSize];
        _frameReadedSize = 0;
        OSStatus ret = AudioQueueNewOutput(&description, audioQueueOutputCallback, (__bridge void * _Nullable)(self), NULL, NULL, 0, &_audioQueue);
        if (ret != noErr) {
            NSLog(@"[RENDER][AUDIO]: can not init audio output");
            return nil;
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
    [_queue clear];
    if (_audioQueue != NULL) {
        AudioQueueReset(_audioQueue);
    }
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
}

@end
