//
//  VCPriorityObjectQueue.h
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/26.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kVCPriorityIDR (-1)

static const char *kVCPriorityObjectRuntimePriorityKey;
static const char *kVCPriorityObjectRuntimeNextKey;
static const char *kVCPriorityObjectRuntimeLastKey;

@interface VCPriorityObjectQueue : NSObject

/**
 是否需要线程安全
 */
@property (nonatomic, assign) BOOL isThreadSafe;

- (instancetype)initWithSize:(int)size
                isThreadSafe:(BOOL)isThreadSafe;

- (void)clear;

- (BOOL)push:(NSObject *)object
    priority:(NSInteger)priority;

- (NSObject *)pull;

- (void)wakeupReader;

- (int)count;

- (int)size;

- (BOOL)isFull;

@end
