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
- (VCBaseImage *)decode:(VCBaseFrame *)frame DEPRECATED_MSG_ATTRIBUTE("由于FFmpeg问题，frame里面可能包含多个帧，请使用decodeFrame:completion: 或 decodeWithFrame:");

/**
 回调block

 @param frame 原始帧
 @param block 回调block
 */

- (void)decodeFrame:(VCBaseFrame *)frame
         completion:(void (^)(VCBaseImage * image))block;

/**
 delegate 方式回调
 !! 需要注意的是，对于一个VCBaseFrame，如果为一个keyFrame，则parseData必须为 |SPS|PPS|SEI(可选)|IDR|
    对于一个非keyFrame, parseData必须为 |SEI(可选)|NAL| 
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
@property (nonatomic, weak) id<VCBaseDecoderDelegate> delegate;
@property (nonatomic, assign) NSInteger fps;
@end
