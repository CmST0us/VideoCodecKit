//
//  VCHeapPriorityObjectQueue.h
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/27.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 堆排序优先级队列
 */
@interface VCHeapPriorityObjectQueue : NSObject
/**
 是否需要线程安全
 */
@property (nonatomic, assign) BOOL isThreadSafe;
// 参考VCPriotiryObjectQueue
@property (nonatomic, assign) NSInteger watermark;

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
