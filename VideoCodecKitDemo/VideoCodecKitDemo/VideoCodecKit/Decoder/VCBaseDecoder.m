//
//  VCBaseDecoder.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/9.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import "VCBaseDecoder.h"

@implementation VCBaseDecoder

- (instancetype)init {
    self = [super init];
    if (self) {
        // 状态机配置
        self.actionStateMap = @{
                                @"setup": @[@(VCBaseDecoderStateReady), @(VCBaseDecoderStateInit), @(VCBaseDecoderStateStop)],
                                @"run": @[@(VCBaseDecoderStateRunning), @(VCBaseDecoderStateReady), @(VCBaseDecoderStatePause)],
                                @"invalidate": @[@(VCBaseDecoderStateStop), @(VCBaseDecoderStateReady), @(VCBaseDecoderStateRunning), @(VCBaseDecoderStatePause)],
                                @"pause": @[@(VCBaseDecoderStatePause), @(VCBaseDecoderStateRunning)],
                                @"resume": @[@(VCBaseDecoderStatePause), @(VCBaseDecoderStateRunning)],
                                };
        self.currentState = @(VCBaseDecoderStateInit);
    }
    return self;
}

- (instancetype)initWithConfig:(VCBaseDecoderConfig *)config {
    self = [self init];
    if (self) {
        _config = config;
    }
    return self;
}

#pragma mark - Public Method
- (void)setup {
    [self commitStateTransition];
}

- (void)run {
    [self commitStateTransition];
}

- (void)invalidate {
    [self commitStateTransition];
}

- (void)pause {
    [self commitStateTransition];
}

- (void)resume {
    [self commitStateTransition];
}


- (id<VCFrameTypeProtocol>)decode:(id<VCFrameTypeProtocol>)frame {
    if (self.currentState.unsignedIntegerValue != VCBaseDecoderStateRunning) {
        return nil;
    }
    return nil;
}


- (void)decodeFrame:(id<VCFrameTypeProtocol>)frame
         completion:(void (^)(id<VCFrameTypeProtocol>))block {
    if (self.currentState.unsignedIntegerValue != VCBaseDecoderStateRunning) {
        return;
    }
}

- (void)decodeWithFrame:(id<VCFrameTypeProtocol>)frame {
    if (self.currentState.unsignedIntegerValue != VCBaseDecoderStateRunning) {
        return;
    }
}

@end
