//
//  VCBaseDecoder.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/9.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import "VCBaseDecoder.h"

@implementation VCBaseDecoder

- (instancetype)initWithConfig:(VCBaseDecoderConfig *)config {
    self = [super init];
    if (self) {
        _currentState = VCDecoderStateInit;
        _config = config;
        _currentState = VCDecoderStateReady;
    }
    return self;
}

- (instancetype)init {
    return [self initWithConfig:[VCBaseDecoderConfig defaultConfig]];
}

- (BOOL)setConfig:(VCBaseDecoderConfig *)aConfig {
    if (self.currentState != VCDecoderStateReady) {
        return NO;
    }
    _config = aConfig;
    return YES;
}

- (BOOL)start {
    if (self.currentState != VCDecoderStateReady) {
        return NO;
    }
    _currentState = VCDecoderStateRunning;
    return YES;
}

- (BOOL)startWithConfig:(VCBaseDecoderConfig *)aConfig {
    if ([self setConfig:aConfig]) {
        return [self start];
    }
    return NO;
}

- (BOOL)pause {
    if (self.currentState != VCDecoderStateRunning) {
        return NO;
    }
    _currentState = VCDecoderStateWait;
    return YES;
}

- (BOOL)resume {
    if (self.currentState != VCDecoderStateWait) {
        return NO;
    }
    _currentState = VCDecoderStateRunning;
    return YES;
}

- (BOOL)stop {
    if (self.currentState == VCDecoderStateWait || self.currentState == VCDecoderStateRunning) {
        _currentState = VCDecoderStateReady;
        return YES;
    }
    return NO;
}

- (BOOL)reset {
    if (self.currentState != VCDecoderStateReady) {
        return NO;
    }
    return YES;
}

- (BOOL)resetUsingConfig:(VCBaseDecoderConfig *)aConfig {
    if ([self setConfig:aConfig]) {
        return [self reset];
    }
    return NO;
}

@end
