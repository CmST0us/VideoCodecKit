//
//  VCEncoderController.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/10/23.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import "VCEncoderController.h"

@implementation VCEncoderController
- (instancetype)init {
    self = [super init];
    if (self) {
        VCBaseEncoderConfig *config = [[VCBaseEncoderConfig alloc] init];
        config.width = 720;
        config.height = 480;
        config.fps = 30;
        config.bitrate = config.height * config.width * 3 * 8;
        config.codecType = kCMVideoCodecType_H264;
        config.gopSize = 20;
        config.quality = VCBaseEncoderQualityNormal;
        config.isRealTime = YES;
        
        _encoder = [[VCVTH264Encoder alloc] initWithConfig:config];
        [_encoder setup];
    }
    return self;
}

- (void)runEncoder {
    [_encoder run];
}
@end
