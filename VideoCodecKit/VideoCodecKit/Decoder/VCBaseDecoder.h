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
#import "VCBaseImage.h"
#import "VCBaseCodec.h"


@protocol VCBaseDecoderProtocol<NSObject>
@optional
/**
 一进一出，填充frame

 @param frame 原始帧
 @return 解码图片
 */
- (VCBaseImage *)decode:(VCBaseFrame *)frame;

/**
 回调block

 @param frame 原始帧
 @param block 回调block
 */

- (void)decodeFrame:(VCBaseFrame *)frame
         completion:(void (^)(VCBaseImage * image))block;

/**
 delegate 方式回调

 @param frame 原始帧
 */
@required
- (void)decodeWithFrame:(VCBaseFrame *)frame;

@end

@class VCBaseDecoder;
@protocol VCBaseDecoderDelegate<NSObject>
- (void)decoder:(VCBaseDecoder *)decoder didProcessImage:(VCBaseImage *)image;
@end


@interface VCBaseDecoder : VCBaseCodec <VCBaseDecoderProtocol>

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
