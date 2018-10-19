//
//  VCBaseFrameParser.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/9.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import "VCBaseFrameParser.h"

@implementation VCBaseFrameParser
- (instancetype)init {
    self = [super init];
    if (self) {
        _pasrseCount = 0;
        _useDelegate = YES;
    }
    return self;
}

- (NSInteger)parseData:(void *)buffer length:(NSInteger)length {
    return -1;
}

- (NSInteger)parseData:(void *)buffer length:(NSInteger)length completion:(void (^)(VCBaseFrame * _Nonnull))block {
    return -1;
}

- (VCBaseFrame *)parseData:(uint8_t *)buffer length:(NSInteger)length usedLength:(NSInteger *)usedLength {
    return nil;
}

- (void)reset {
    
}

@end
