//
//  VCH264Frame.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/9.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import "VCH264Frame.h"

@implementation VCH264Frame
- (instancetype)init {
    self = [super init];
    if (self) {
        _isSPS = NO;
        _isIDR = NO;
        _isPPS = NO;
        _width = 0;
        _height = 0;
        _frameData = nil;
        _frameSize = 0;
        _parserData = nil;
        _pasrserSize = 0;
        _frameIndex = 0;
    }
    return self;
}

- (NSString *)frameClassString {
    return NSStringFromClass(self);
}
@end
