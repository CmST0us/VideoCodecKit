//
//  VCH264EncoderConfig.m
//  VideoCodecKit
//
//  Created by CmST0us on 2018/10/30.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import "VCH264EncoderConfig.h"

@implementation VCH264EncoderConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        _codecType = kCMVideoCodecType_H264;
    }
    return self;
}

+ (VCH264EncoderConfig *)defaultConfig {
    VCH264EncoderConfig *config = [[VCH264EncoderConfig alloc] init];
    config.width = 1920;
    config.height = 1080;
    config.fps = 30;
    config.bitrate = config.height * config.width * 3 * 8;
    config.keyFrameIntervalDuration = 1;
    config.keyFrameInterval = config.fps;
    config.quality = VCH264EncoderQualityFast;
    config.isRealTime = YES;
    config.enableBFrame = NO;
    return config;
}

@end
