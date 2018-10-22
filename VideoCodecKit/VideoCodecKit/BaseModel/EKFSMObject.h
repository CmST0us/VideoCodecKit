//
//  EKFSMObject.h
//  FSMDemo
//
//  Created by CmST0us on 2018/9/15.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>

// 接口设计烂的一批
// 不要用！！！！！！！！！！！1
// Objective-C performSelector 兼容性太差了。
// [TODO] 找一个替代状态转移的方案

#define FSM(_s_) performSelector:@selector(_s_)

@interface NSNumber (EKFSMObjectStateUtil)
- (BOOL)isKindOfState:(NSArray<NSNumber *> *)states;
- (BOOL)isEqualToInteger:(NSInteger)state;
@end

@interface EKFSMObject: NSObject

@property (nonatomic, strong) NSDictionary *actionStateMap;
@property (nonatomic, strong) NSNumber *currentState;

- (void)commitStateTransition;
- (void)rollbackStateTransition;

@end

