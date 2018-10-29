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
// 固定为3帧，以适应重排帧
@property (nonatomic, readonly) NSInteger watermark;
// 默认YES，一般用于流结束时设置。设置为NO后如果数据个数不满水位，不会等待了，直接返回nil避免线程等待卡死主线程。
@property (nonatomic, assign) BOOL shouldWaitWhenPullFailed;

/* [TODO]: 支持重排帧，队列需要有3帧的水位。后续版本需要提供流结束时放掉水位的功能
// 用与标记流是否结束。配合watermark使用
// 在VCPreviewer中，由于使用了三个数据队列.故需要标记出parse结束的状态，以便显示出低于watermark的那几帧图像
//@property (nonatomic, assign) BOOL isEnd;
*/

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
