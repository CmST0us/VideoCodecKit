//
//  VCBaseEncoder.h
//  VideoCodecKit
//
//  Created by CmST0us on 2018/10/23.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import "VCBaseCodec.h"

@class VCBaseImage;
@class VCBaseFrame;
@class VCBaseEncoder;
@class VCBaseEncoderConfig;

@protocol VCBaseEncoderProtocol <NSObject>
@optional
/**
 编码一张图

 @param image 编码图像
 @return 编码帧
 */
- (VCBaseFrame *)encode:(VCBaseImage *)image;

/**
 回调block

 @param image 编码图像
 @param block 编码成功回调
 */
- (void)encodeImage:(VCBaseImage *)image
     withCompletion:(void (^)(VCBaseFrame *frame))block;

@required
/**
 delegate 回调

 @param image 编码图像
 */
- (void)encodeWithImage:(VCBaseImage *)image;
@end

/**
 编码器Delegate
 */
@protocol VCBaseEncoderDelegate <NSObject>
- (void)encoder:(VCBaseEncoder *)encoder didProcessFrame:(VCBaseFrame *)frame;
@end

@interface VCBaseEncoder : VCBaseCodec<VCBaseEncoderProtocol>

@property (nonatomic, strong) VCBaseEncoderConfig *config;
@property (nonatomic, weak) id<VCBaseEncoderDelegate> delegate;

@property (nonatomic, assign) NSUInteger pts;

- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithConfig:(VCBaseEncoderConfig *)config;
@end
