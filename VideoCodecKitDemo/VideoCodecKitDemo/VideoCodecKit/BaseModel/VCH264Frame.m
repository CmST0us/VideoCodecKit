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
        _frameType = VCH264FrameTypeUnknown;
        _width = 0;
        _height = 0;
        _parseData = nil;
        _parseSize = 0;
        _frameIndex = 0;
        _image = nil;
    }
    return self;
}

- (instancetype)initWithWidth:(NSUInteger)width
                       height:(NSUInteger)height
                  bytesPerRow:(NSUInteger)bytesPerRow{
    self = [self init];
    _width = width;
    _height = height;
    _image = [[VCYUV422Image alloc] initWithWidth:width height:height];
    return self;
}

- (void)createParseDaraWithSize:(NSUInteger)size {
    self.parseSize = size;
    self.parseData = (uint8_t *)malloc(size);
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
    
    return [NSString stringWithFormat:@"frame:\nwidth x height: %ld x %ld;\nparseSize: %ld;\nparseData: %@\n", self.width, self.height, self.parseSize, parseDataString];
}

- (void)dealloc {
    if (self.parseData != nil) {
        free(self.parseData);
        self.parseData = nil;
        self.parseSize = 0;
    }
}
@end
