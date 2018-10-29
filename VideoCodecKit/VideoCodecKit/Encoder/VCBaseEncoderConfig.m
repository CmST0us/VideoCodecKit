//
//  VCBaseEncoderConfig.m
//  VideoCodecKit
//
//  Created by CmST0us on 2018/10/23.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import "VCBaseEncoderConfig.h"

@implementation VCBaseEncoderConfig
@synthesize codecType = _codecType;
- (instancetype)init {
    self = [super init];
    if (self) {
        _codecType = kCMVideoCodecType_H264;
    }
    return self;
}

@end
