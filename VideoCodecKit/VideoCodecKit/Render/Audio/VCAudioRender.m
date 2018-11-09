//
//  VCAudioRender.m
//  VideoCodecKit
//
//  Created by CmST0us on 2018/11/8.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "VCAudioFrameParser.h"
#import "VCAudioRender.h"
#import "VCAudioFrame.h"

#define kVCAudioRenderBufferSize 3

@interface VCAudioRender ()<VCBaseFrameParserDelegate> {
    AudioQueueBufferRef _audioBuffer[kVCAudioRenderBufferSize];
}

@property (nonatomic, strong) VCAudioFrameParser *renderParser;
@property (nonatomic, assign) AudioQueueRef audioQueue;

@end

@implementation VCAudioRender

#pragma mark - AudioQueue Callback
void audioQueueOutputCallback(void * __nullable   inUserData,
                              AudioQueueRef       inAQ,
                              AudioQueueBufferRef inBuffer) {
    VCAudioRender *render = (__bridge VCAudioRender *)(inUserData);
}

#pragma mark - Private Method

#pragma mark - Public Method
- (instancetype)init {
    self = [super init];
    if (self){
        
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
}

#pragma mark - Override Method
- (NSArray<NSString *> *)supportRenderClassName {
    return @[
             NSStringFromClass([VCAudioFrameParser class]),
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
    
    VCAudioFrameParser *parser = (VCAudioFrameParser *)object;
    if (parser != nil
        && [parser isKindOfClass:[VCAudioFrameParser class]]) {
        self.renderParser = parser;
        self.renderParser.delegate = self;
    }
}

#pragma mark - Audio Frame Parser Delegate
- (void)frameParserDidParseFrame:(VCBaseFrame *)aFrame {
    if (aFrame == nil
        || ![aFrame isKindOfClass:[VCAudioFrame class]]) {
        return;
    }
    
    VCAudioFrame *audioFrame = (VCAudioFrame *)aFrame;
}
@end
