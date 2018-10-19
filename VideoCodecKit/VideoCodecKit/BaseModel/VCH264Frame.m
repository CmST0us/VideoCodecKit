//
//  VCH264Frame.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/9.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import "VCH264Frame.h"
#import "VCVideoFPS.h"

@interface VCH264Frame () {
    uint8_t *_parseDataPtr;
}

@end

@implementation VCH264Frame
- (instancetype)init {
    self = [super init];
    if (self) {
        _width = 0;
        _height = 0;
        _parseData = nil;
        _parseDataPtr = NULL;
        _parseSize = 0;
        _frameIndex = 0;
    }
    return self;
}

- (instancetype)initWithWidth:(NSUInteger)width
                       height:(NSUInteger)height {
    self = [self init];
    _width = width;
    _height = height;
    return self;
}

- (void)createParseDataWithSize:(NSUInteger)size {
    self.parseSize = size;
    // 便于后面不同 startCode 转换
    _parseDataPtr = (uint8_t *)malloc(size + 1);
    self.parseData = _parseDataPtr + 1;
    memset(self.parseData, 0, size);
}


- (NSString *)description {
    
    uint8_t *parseDataPtr = (uint8_t *)self.parseData;
    NSMutableString *parseDataString = [[NSMutableString alloc] init];
    for (int i = 0; i < self.parseSize; ++i) {
        [parseDataString appendFormat:@"%.2X ", *(parseDataPtr + i)];
    }
    
    NSDictionary *frameTypeDescdict = @{
                                        @(0): @"VCH264FrameTypeUnknown",
                                        @(1): @"VCH264FrameTypeSlice",
                                        @(5): @"VCH264FrameTypeIDR",
                                        @(6): @"VCH264FrameTypeSEI",
                                        @(7): @"VCH264FrameTypeSPS",
                                        @(8): @"VCH264FrameTypePPS",
                                        };
    
    NSDictionary *sliceTypeDescDict = @{
                                        @(0): @"VCH264SliceTypeNone", ///< Undefined
                                        @(1): @"VCH264SliceTypeI",     ///< Intra
                                        @(2): @"VCH264SliceTypeP",     ///< Predicted
                                        @(3): @"VCH264SliceTypeB",     ///< Bi-dir predicted
                                        @(4): @"VCH264SliceTypeS",     ///< S(GMC)-VOP MPEG-4
                                        @(5): @"VCH264SliceTypeSI",    ///< Switching Intra
                                        @(6): @"VCH264SliceTypeSP",    ///< Switching Predicted
                                        @(7): @"VCH264SliceTypeBI",    ///< BI type
                                        };
    
    return [NSString stringWithFormat:@"\nframe:\n\
            width x height: %lu x %lu;\n\
            frameType: %@\n\
            parseSize: %ld;\n", self.width, self.height, frameTypeDescdict[@(self.frameType)], self.parseSize];
}

- (void)dealloc {
    if (_parseDataPtr != NULL) {
        free(_parseDataPtr);
        self.parseData = nil;
        _parseDataPtr = NULL;
        self.parseSize = 0;
    }
}
@end
