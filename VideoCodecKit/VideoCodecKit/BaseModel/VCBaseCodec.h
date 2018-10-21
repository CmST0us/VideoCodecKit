//
//  VCBaseCodec.h
//  VideoCodecKit
//
//  Created by CmST0us on 2018/10/21.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EKFSMObject.h"

// 解码器状态机
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
 解码器状态
 
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

/**
 编解码器父类，维护了编解码器状态机。
 继承的子类都应该实现 VCBaseDecoderProtocol 接口
 */

@interface VCBaseCodec : EKFSMObject

/**
 配置
 */
- (void)setup;

/**
 开始
 */
- (void)run;

/**
 释放
 */
- (void)invalidate;

/**
 暂停
 */
- (void)pause;

/**
 继续
 */
- (void)resume;

@end

