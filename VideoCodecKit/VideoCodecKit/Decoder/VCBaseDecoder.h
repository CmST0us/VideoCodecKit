//
//  VCBaseDecoder.h
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/9.
//  Copyright © 2018年 eric3u. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "VCBaseDecoderConfig.h"
#import "VCBaseFrame.h"
#import "VCImageTypeProtocol.h"
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
                              resumu| |pause
                                    | |
                                    |\/
                                    pause
 
 P.S. setup之后的状态都能转到stop
 */

/**
 解码器状态

 - VCBaseDecoderStateInit: 正在初始化
 - VCBaseDecoderStateReady: 初始化完成可以启动
 - VCBaseDecoderStateRunning: 正在运行
 - VCBaseDecoderStatePause: 运行暂停，等待重新调度
 - VCBaseDecoderStateStop: 解码器被invalidate运行停止
 */
typedef NS_ENUM(NSUInteger, VCBaseDecoderState) {
    VCBaseDecoderStateInit,
    VCBaseDecoderStateReady,
    VCBaseDecoderStateRunning,
    VCBaseDecoderStatePause,
    VCBaseDecoderStateStop,
};

@protocol VCBaseDecoderProtocol<NSObject>

/**
 配置解码器
 */
- (void)setup;

/**
 开始解码
 */
- (void)run;

/**
 释放解码器
 */
- (void)invalidate;

/**
 暂停解码
 */
- (void)pause;

/**
 继续解码
 */
- (void)resume;


/**
 一进一出，填充frame

 @param frame 原始帧
 @return 解码图片
 */
- (id<VCImageTypeProtocol>)decode:(VCBaseFrame *)frame;

/**
 回调block

 @param frame 原始帧
 @param block 回调block
 */

- (void)decodeFrame:(VCBaseFrame *)frame
         completion:(void (^)(id<VCImageTypeProtocol> image))block;

/**
 delegate 方式回调

 @param frame 原始帧
 */
- (void)decodeWithFrame:(VCBaseFrame *)frame;

@end

@class VCBaseDecoder;
@protocol VCBaseDecoderDelegate<NSObject>

- (void)decoder:(VCBaseDecoder *)decoder didProcessImage:(id<VCImageTypeProtocol>)image;

@end

/**
 解码器父类，维护了解码器状态机。
 继承的子类都应该实现 VCBaseDecoderProtocol 接口
 */
@interface VCBaseDecoder : EKFSMObject<VCBaseDecoderProtocol>

// 解码器当前状态
@property (nonatomic, readonly) VCBaseDecoderConfig *config;

@property (nonatomic, weak) id<VCBaseDecoderDelegate> delegate;

@property (nonatomic, assign) NSInteger fps;
/**
 使用配置创建解码器

 @param config 配置
 @return 解码器实例
 */
- (instancetype)initWithConfig:(VCBaseDecoderConfig *)config;


@end
