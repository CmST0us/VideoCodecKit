//
//  VCBaseCodec.h
//  VideoCodecKit
//
//  Created by CmST0us on 2018/10/21.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>

// 编解码器状态机
/**
                                        setup
                     +----------------------------------------+
                     |                                        |
                     |                                        |
                     |                                        |
          setup     \/      run               invalidate      |
 init  --------->  ready --------> running --------------> stop
                    ^ |
              resume| |pause
                    | |
                    |\/
                   pause
 
 P.S. setup之后的状态都能转到stop
 */

/**
 编解码器状态
 
 - VCBaseCodecStateInit: 正在初始化
 - VCBaseCodecStateReady: 初始化完成可以启动
 - VCBaseCodecStateRunning: 正在运行
 - VCBaseCodecStatePause: 运行暂停，等待重新调度
 - VCBaseCodecStateStop: 解码器被invalidate运行停止
 */

typedef NS_ENUM(NSUInteger, VCBaseCodecState) {
    VCBaseCodecStateInit,
    VCBaseCodecStateReady,
    VCBaseCodecStateRunning,
    VCBaseCodecStatePause,
    VCBaseCodecStateStop,
};

@interface NSNumber (StateUtil)
- (BOOL)isKindOfState:(NSArray<NSNumber *> *)states;
- (BOOL)isEqualToInteger:(NSInteger)state;
@end

/**
 编解码器父类，维护了编解码器状态机。
 继承的子类都应该实现 VCBaseDecoderProtocol 接口
 */

@interface VCBaseCodec : NSObject

@property (nonatomic, strong) NSDictionary *actionStateMap;
@property (nonatomic, strong) NSNumber *currentState;

- (void)commitStateTransition;
- (void)rollbackStateTransition;

/**
 配置
 */
- (BOOL)setup NS_REQUIRES_SUPER;

/**
 开始
 */
- (BOOL)run NS_REQUIRES_SUPER;

/**
 释放
 */
- (BOOL)invalidate NS_REQUIRES_SUPER;

/**
 暂停
 */
- (BOOL)pause NS_REQUIRES_SUPER;

/**
 继续
 */
- (BOOL)resume NS_REQUIRES_SUPER;

@end

