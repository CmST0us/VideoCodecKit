//
//  VCBaseDecoderConfig.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/9.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import "VCBaseDecoderConfig.h"

#define kVCDefaultBufferSize kVC720P * 3

@implementation VCBaseDecoderConfig

+ (instancetype)defaultConfig {
    VCBaseDecoderConfig *config = [[VCBaseDecoderConfig alloc] init];
    config.bufferSize = kVCDefaultBufferSize;
    config.bufferCountInQueue = 4;
    config.workQueue = dispatch_get_main_queue();
    return config;
}

@end
