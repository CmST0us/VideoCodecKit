//
//  VCSafeBuffer.h
//  VideoCodecKit
//
//  Created by CmST0us on 2018/11/9.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface VCSafeBufferNode: NSObject
@property (nonatomic, readonly) NSData *data;
@property (nonatomic, assign) NSInteger readOffset;
- (instancetype)initWithData:(NSData *)data;
- (NSData *)pull:(NSInteger *)length;
- (NSInteger)length;
- (NSInteger)readableLength;
@end


@interface VCSafeBuffer : NSObject

/**
 是否可以写入数据，默认YES
 */
@property (nonatomic, assign) BOOL canWrite;
/**
 是否开启线程安全
 */
@property (nonatomic, assign) BOOL isThreadSafe;
/**
 拉取失败是否等待并重试，默认YES
 */
@property (nonatomic, assign) BOOL shouldWaitWhenPullFailed;
/**
 创建一个缓冲区
 
 @param isThreadSafe 是否线程安全
 @return 队列实例
 */
- (instancetype)initWithThreadSafe:(BOOL)isThreadSafe;

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
 缓冲区加入数据

 @param data 数据
 @return 是否添加成功
 */
- (BOOL)push:(VCSafeBufferNode *)data;


/**
 拉取数据对象

 @param length
 IN: 希望多少数据
 OUT: 实际拿了多少
 
 @return 拉取的数据
 */
- (NSData *)pull:(NSInteger *)length;


/**
 获取数据，不从缓冲区删除

 @param length
 IN: 希望多少数据
 OUT: 实际拿了多少
 
 @return 获取的数据
 */
- (NSData *)fetch:(NSInteger *)length;

/**
 唤起所有线程
 */
- (void)wakeupReader;
@end

