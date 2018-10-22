//
//  VCBaseCodec.m
//  VideoCodecKit
//
//  Created by CmST0us on 2018/10/21.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import "VCBaseCodec.h"

@implementation NSNumber (StateUtil)

- (BOOL)isKindOfState:(NSArray<NSNumber *> *)states {
    for (NSNumber *number in states) {
        if ([number isKindOfClass:[NSNumber class]]) {
            if ([self isEqualToNumber:number]) {
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL)isEqualToInteger:(NSInteger)state {
    return [self isEqualToNumber:@(state)];
}

@end

@interface VCBaseCodec ()
@property (nonatomic, strong) NSNumber *changingState;
@property (nonatomic, assign) BOOL isChangingState;
@end

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
        self.changingState = @(VCBaseCodecStateInit);
        self.isChangingState = NO;
    }
    return self;
}

#pragma mark - Public Method
- (BOOL)setup {
    return [self tryChangeStateFromSelector:@selector(setup)];
}

- (BOOL)run {
    return [self tryChangeStateFromSelector:@selector(run)];
}

- (BOOL)invalidate {
    return [self tryChangeStateFromSelector:@selector(invalidate)];
}

- (BOOL)pause {
    return [self tryChangeStateFromSelector:@selector(pause)];
}

- (BOOL)resume {
    return [self tryChangeStateFromSelector:@selector(resume)];
}

- (void)commitStateTransition {
    self.currentState = self.changingState;
    self.isChangingState = NO;
}

- (void)rollbackStateTransition {
    self.changingState = self.currentState;
    self.isChangingState = NO;
}

#pragma mark - Private Method
- (BOOL)tryChangeStateFromSelector:(SEL)aSelector {
    /*
     状态map
     { SEL: [targetState, permittedState, ...] }
     */
    if (self.isChangingState == YES) return NO;
    self.isChangingState = YES;
    NSString *invocationSelectorString = NSStringFromSelector(aSelector);
    NSArray *stateTransArray = self.actionStateMap[invocationSelectorString];
    if (stateTransArray && stateTransArray.count > 1) {
        NSNumber *targetState = stateTransArray[0];
        BOOL canTransit = NO;
        for (NSNumber *permittedState in [stateTransArray subarrayWithRange:NSMakeRange(1, stateTransArray.count - 1)]) {
            if ([self.currentState isEqualToNumber:permittedState]) {
                canTransit = YES;
                break;
            }
        }
        if (canTransit) {
            self.changingState = targetState;
            return YES;
        }
    }
    return NO;
}

@end
