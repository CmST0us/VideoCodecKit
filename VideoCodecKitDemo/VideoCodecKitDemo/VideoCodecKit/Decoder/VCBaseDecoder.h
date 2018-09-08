//
//  VCBaseDecoder.h
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/9.
//  Copyright © 2018年 eric3u. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "VCBaseDecoderConfig.h"

/**
 解码器状态

 - VCDecoderStateInit: 正在初始化
 - VCDecoderStateReady: 初始化完成可以启动
 - VCDecoderStateRunning: 正在运行
 - VCDecoderStateWait: 运行暂停，等待重新调度
 - VCDecoderStateError: 出现错误
 */
typedef NS_ENUM(NSUInteger, VCDecoderState) {
    VCDecoderStateInit,
    VCDecoderStateReady,
    VCDecoderStateRunning,
    VCDecoderStateWait,
    VCDecoderStateError,
};

NS_ASSUME_NONNULL_BEGIN

@protocol VCBaseDecoderProtocol
@required
/**
 启动解码器：状态从Ready变为Running
 */
- (BOOL)start;

/**
 暂停解码器：状态从Running变为Wait
 */
- (BOOL)pause;

/**
 继续解码器：状态从Wait变为Running
 */
- (BOOL)resume;
/**
 停止解码器：状态从(Running||Wait)变为Ready
 */
- (BOOL)stop;

/**
 重置解码器：只有在状态为Ready才能重置
 */
- (BOOL)reset;

@end

/**
 解码器父类，维护了解码器状态机。
 继承的子类都应该实现 VCBaseDecoderProtocol jie kou
 */
@interface VCBaseDecoder : NSObject<VCBaseDecoderProtocol>

// 解码器当前状态
@property (nonatomic, readonly) VCDecoderState currentState;
@property (nonatomic, readonly) VCBaseDecoderConfig *config;

/**
 使用配置创建解码器

 @param config 配置
 @return 解码器实例
 */
- (instancetype)initWithConfig:(VCBaseDecoderConfig *)config;

- (BOOL)startWithConfig:(VCBaseDecoderConfig *)aConfig;
- (BOOL)resetUsingConfig:(VCBaseDecoderConfig *)aConfig;
/**
 使用新的参数配置解码器
 调用前应保证解码器状态处于Ready状态
 
 @param aConfig 配置
 @return 是否配置成功
 */
- (BOOL)setConfig:(VCBaseDecoderConfig *)aConfig;

@end
NS_ASSUME_NONNULL_END
