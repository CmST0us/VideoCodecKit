//
//  VCH264EncoderConfig.h
//  VideoCodecKit
//
//  Created by CmST0us on 2018/10/30.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import "VCBaseEncoderConfig.h"

typedef NS_ENUM(NSUInteger, VCH264EncoderQuality) {
    VCH264EncoderQualitySplendid,
    VCH264EncoderQualityGood,
    VCH264EncoderQualityNormal,
    VCH264EncoderQualityFast,
};

@interface VCH264EncoderConfig : VCBaseEncoderConfig

@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, assign) NSInteger bitrate;
@property (nonatomic, assign) NSInteger fps;

@property (nonatomic, assign) BOOL isRealTime;
@property (nonatomic, assign) BOOL enableBFrame;
/**
 每隔多少秒一个I帧
 */
@property (nonatomic, assign) NSInteger keyFrameIntervalDuration;
@property (nonatomic, assign) NSInteger keyFrameInterval;
@property (nonatomic, assign) VCH264EncoderQuality quality;

+ (VCH264EncoderConfig *)defaultConfig;

@end

