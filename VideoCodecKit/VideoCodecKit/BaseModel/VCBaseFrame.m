//
//  VCBaseFrame.m
//  VideoCodecKit
//
//  Created by CmST0us on 2018/10/19.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import "VCBaseFrame.h"

CONST_STRING(kVCBaseFrameUserInfoFFmpegAVCodecContextKey);

@implementation VCBaseFrame

- (instancetype)init {
    self = [super init];
    if (self) {
        _userInfo = [NSMutableDictionary dictionary];
    }
    return self;
}
@end
