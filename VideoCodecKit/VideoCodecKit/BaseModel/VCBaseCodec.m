//
//  VCBaseCodec.m
//  VideoCodecKit
//
//  Created by CmST0us on 2018/10/21.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import "VCBaseCodec.h"

@implementation VCBaseCodec
- (instancetype)init {
    self = [super init];
    if (self) {
        // 状态机配置
        self.actionStateMap = @{
                                @"setup": @[@(VCBaseCodecStateReady), @(VCBaseCodecStateInit), @(VCBaseCodecStateStop)],
                                @"run": @[@(VCBaseCodecStateRunning), @(VCBaseCodecStateReady), @(VCBaseCodecStatePause)],
                                @"invalidate": @[@(VCBaseCodecStateStop), @(VCBaseCodecStateReady), @(VCBaseCodecStateRunning), @(VCBaseCodecStatePause)],
                                @"pause": @[@(VCBaseCodecStatePause), @(VCBaseCodecStateRunning)],
                                @"resume": @[@(VCBaseCodecStatePause), @(VCBaseCodecStateRunning)],
                                };
        self.currentState = @(VCBaseCodecStateInit);
    }
    return self;
}
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
@end
