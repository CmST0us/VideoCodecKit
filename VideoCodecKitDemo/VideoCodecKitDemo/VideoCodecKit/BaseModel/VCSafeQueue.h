//
//  VCSafeQueue.h
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/21.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <pthread.h>

@interface VCSafeQueue : NSObject
/**
 是否开启线程安全
 */
@property (nonatomic, assign) BOOL isThreadSafe;

/**
 创建一个队列

 @param size 队列大小
 @param isThreadSafe 是否线程安全
 @return 队列实例
 */
- (instancetype)initWithSize:(int)size
                  threadSafe:(BOOL)isThreadSafe;
/**
 创建一个线程安全队列

 @param size 队列大小
 @return VCSafeQueue实例
 */
- (instancetype)initWithSize:(int)size;

/**
 移除队列所有对象
 */
- (void)clear;

/**
 *  Gets the number of objects in queue.
 *
 *  @return the number of objects in queue
 */
/**
 当前队列对象个数

 @return 当前队列对象个数
 */
- (int)count;


/**
 当前队列大小

 @return 当前队列大小
 */
- (int)size;

/**
 把数据压入队列中，不发生内存拷贝，消费者必须释放取回的数据

 @param buf 数据地址
 @param len 数据大小
 @return 操作是否成功
 */
- (BOOL)push:(uint8_t *)buf length:(int)len;


/**
 从队列中拉取数据

 @param len 数据长度
 @return 数据地址
 */
- (uint8_t *)pull:(int *)len;


/**
 队列是否满

 @return 是否满
 */
- (BOOL)isFull;


/**
 唤起所有线程
 */
- (void)wakeupReader;

@end

