//
//  VCBaseDecoderConfig.h
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/9.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface VCBaseDecoderConfig : NSObject
@property (nonatomic, assign) NSUInteger bufferSize;
@property (nonatomic, assign) NSUInteger bufferCountInQueue;
@property (nonatomic, strong) dispatch_queue_t workQueue;

/**
 返回默认配置
 默认在主线程工作

 @return 配置
 */
+ (instancetype)defaultConfig;

@end
NS_ASSUME_NONNULL_END
