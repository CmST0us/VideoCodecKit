//
//  EKFSMObject.m
//  FSMDemo
//
//  Created by CmST0us on 2018/9/15.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import "EKFSMObject.h"

@implementation NSNumber (EKFSMObjectStateUtil)

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

@interface EKFSMObject ()
@property (nonatomic, strong) NSNumber *changingState;
@end

@implementation EKFSMObject

- (instancetype)init {
    self = [super init];
    if (self) {
        _actionStateMap = @{};
        _currentState = @(0);
        _changingState = @(0);
        
    }
    return self;
}

- (BOOL)tryChangeStateFromSelector:(SEL)aSelector {
    /*
     状态map
     { SEL: [targetState, permittedState, ...] }
     */
    
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

- (id)performSelector:(SEL)aSelector {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    return [self performSelector:aSelector withObject:nil];
#pragma clang diagnostic pop
}

- (id)performSelector:(SEL)aSelector withObject:(id)object {
    if ([self tryChangeStateFromSelector:aSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if ([super respondsToSelector:aSelector]) {
            [super performSelector:aSelector withObject:object];
            return nil;
        }
#pragma clang diagnostic pop
    }
    [[NSException exceptionWithName:@"Can not incovacte" reason:@"Bad state transit" userInfo:nil] raise];
    return nil;
}


- (void)commitStateTransition {
    self.currentState = self.changingState;
}

- (void)rollbackStateTransition {
    self.changingState = self.currentState;
}
@end

