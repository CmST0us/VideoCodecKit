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
        _sliceType = VCH264SliceTypeNone;
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
                       height:(NSUInteger)height {
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
            width x height: %ld x %ld;\n\
            frameType: %@\n\
            sliceType: %@\n\
            parseSize: %ld;\n", self.width, self.height, frameTypeDescdict[@(self.frameType)], sliceTypeDescDict[@(self.sliceType)], self.parseSize];
}

- (void)dealloc {
    if (self.parseData != nil) {
        free(self.parseData);
        self.parseData = nil;
        self.parseSize = 0;
    }
}
@end
