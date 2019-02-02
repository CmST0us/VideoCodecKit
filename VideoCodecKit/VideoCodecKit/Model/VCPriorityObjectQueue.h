//
//  VCPriorityObjectQueue.h
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/26.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCMarco.h"

static const char *kVCPriorityObjectRuntimePriorityKey;
static const char *kVCPriorityObjectRuntimeNextKey;
static const char *kVCPriorityObjectRuntimeLastKey;

@interface VCPriorityObjectQueue : NSObject

/**
 是否需要线程安全
 */
@property (nonatomic, assign) BOOL isThreadSafe;
// 默认为3帧。队列需要有3帧的水位，以适应重排帧。可以在流结束的时候放掉水位（设为0），但是需要注意和解码，显示线程的同步
@property (nonatomic, assign) NSInteger watermark;
// 默认YES，一般用于流结束时设置。设置为NO后如果数据个数不满水位，不会等待了，直接返回nil避免线程等待卡死主线程。
@property (nonatomic, assign) BOOL shouldWaitWhenPullFailed;

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
