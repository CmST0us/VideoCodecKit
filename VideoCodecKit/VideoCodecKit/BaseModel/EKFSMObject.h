//
//  EKFSMObject.h
//  FSMDemo
//
//  Created by CmST0us on 2018/9/15.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FSM(_s_) performSelector:@selector(_s_)

@interface EKFSMObject: NSObject

@property (nonatomic, strong) NSDictionary *actionStateMap;
@property (nonatomic, strong) NSNumber *currentState;

- (void)commitStateTransition;
- (void)rollbackStateTransition;

@end

