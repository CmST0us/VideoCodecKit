//
//  VCSafeObjectQueue.h
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/21.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <pthread.h>

@interface VCSafeObjectQueue : NSObject

/**
 是否开启线程安全
 */
@property (nonatomic, assign) BOOL isThreadSafe;
/**
 拉取失败是否等待并重试，默认YES
 */
@property (nonatomic, assign) BOOL shouldWaitWhenPullFailed;
/**
 创建一个队列
 
 @param size 队列大小
 @param isThreadSafe 是否线程安全
 @return 队列实例
 */
- (instancetype)initWithSize:(int)size
                  threadSafe:(BOOL)isThreadSafe NS_DESIGNATED_INITIALIZER;
/**
 创建一个线程安全队列
 
 @param size 队列大小
 @return VCSafeObjectQueue实例
 */
- (VCSafeObjectQueue *)initWithSize:(int)size;

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
 把对象压入队列中

 @param object 对象
 @return 操作是否成功
 */
- (BOOL)push:(NSObject *)object;


/**
 从队列中拉取对象
 
 @return 对象
 */
- (NSObject *)pull;

/**
 只取队头对象，不出队列

 @return 对象
 */
- (NSObject *)fetch;
/**
 队列是否满
 
 @return 是否满
 */
- (BOOL)isFull;


/**
 唤起所有线程
 */
- (void)wakeupReader;


/**
 阻塞等待，有空间时返回
 */
- (void)waitForCapacity;

@end

