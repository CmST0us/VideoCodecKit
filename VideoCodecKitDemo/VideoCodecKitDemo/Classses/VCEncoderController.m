//
//  VCEncoderController.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/10/23.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import "VCEncoderController.h"

@interface VCEncoderController ()
@property (nonatomic, strong) NSOutputStream *writeStram;
@end

@implementation VCEncoderController

- (instancetype)init {
    self = [super init];
    if (self) {
        VCBaseEncoderConfig *config = [[VCBaseEncoderConfig alloc] init];
        config.width = 1920;
        config.height = 1080;
        config.fps = 60;
        config.bitrate = config.height * config.width * 3 * 8;
        config.codecType = kCMVideoCodecType_H264;
        config.gopSize = 20;
        config.quality = VCBaseEncoderQualitySpliendid;
        config.isRealTime = YES;
        
        _encoder = [[VCVTH264Encoder alloc] initWithConfig:config];
        _encoder.delegate = self;
        [_encoder setup];
    }
    return self;
}

- (void)runEncoder {
    self.writeStram = [[NSOutputStream alloc] initToFileAtPath:self.outputFile append:YES];
    [self.writeStram open];
    [_encoder run];
}

- (void)encoder:(VCBaseEncoder *)encoder didProcessFrame:(VCBaseFrame *)frame {
    [self.writeStram write:frame.parseData maxLength:frame.parseSize];
}

@end
