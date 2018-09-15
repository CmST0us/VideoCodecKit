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
        _parseData = nil;
        _parseSize = 0;
        _frameIndex = 0;
    }
    return self;
}

- (NSString *)frameClassString {
    return NSStringFromClass([self class]);
}

- (NSString *)description {
    uint8_t *parseDataPtr = (uint8_t *)self.parseData;
    NSMutableString *parseDataString = [[NSMutableString alloc] init];
    for (int i = 0; i < self.parseSize; ++i) {
        [parseDataString appendFormat:@"%.2X ", *(parseDataPtr + i)];
    }
    
    return [NSString stringWithFormat:@"frame:\nwidth x height: %ld x %ld;\nframeSize: %ld;\nparseSize: %ld;\nparseData: %@\n", self.width, self.height, self.frameSize, self.parseSize, parseDataString];
}

- (void)dealloc {
    if (self.frameData != nil) {
        free(self.frameData);
        self.frameData = nil;
    }
    
    if (self.parseData != nil) {
        free(self.parseData);
        self.frameData = nil;
    }
}
@end
