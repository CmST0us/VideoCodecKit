//
//  VCVTH264Encoder.h
//  VideoCodecKit
//
//  Created by CmST0us on 2018/10/23.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import "VCBaseEncoder.h"
#import "VCH264EncoderConfig.h"

@interface VCVTH264Encoder : VCBaseEncoder

@property (nonatomic, strong) VCH264EncoderConfig *config;
/**
 初始化方法

 @param config 编码器配置
 @return 编码起
 */
- (instancetype)initWithConfig:(VCH264EncoderConfig *)config;

/**
 使用sps

 @param spsData sps数据，注意不带start code
 */
- (void)useSPS:(NSData *)spsData;
/**
 使用pps
 
 @param ppsData pps数据，注意不带start code
 */
- (void)usePPS:(NSData *)ppsData;

@end
