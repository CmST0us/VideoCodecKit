//
//  VCBaseEncoderConfig.h
//  VideoCodecKit
//
//  Created by CmST0us on 2018/10/23.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

typedef NS_ENUM(NSUInteger, VCBaseEncoderQuality) {
    VCBaseEncoderQualitySplendid,
    VCBaseEncoderQualityGood,
    VCBaseEncoderQualityNormal,
    VCBaseEncoderQualityFast,
};

@interface VCBaseEncoderConfig : NSObject
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, assign) NSInteger bitrate;
@property (nonatomic, assign) NSInteger fps;

@property (nonatomic, assign) CMVideoCodecType codecType;

@property (nonatomic, assign) BOOL isRealTime;
@property (nonatomic, assign) BOOL enableBFrame;
/**
 每隔多少秒一个I帧
 */
@property (nonatomic, assign) NSInteger keyFrameIntervalDuration;
@property (nonatomic, assign) NSInteger keyFrameInterval;
@property (nonatomic, assign) VCBaseEncoderQuality quality;
@end

