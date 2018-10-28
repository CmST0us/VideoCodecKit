//
//  VCBaseEncoderConfig.m
//  VideoCodecKit
//
//  Created by CmST0us on 2018/10/23.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import "VCBaseEncoderConfig.h"

@implementation VCBaseEncoderConfig
- (instancetype)init {
    self = [super init];
    if (self) {
        _fps = kVCDefaultFPS;
    }
    return self;
}
@end
