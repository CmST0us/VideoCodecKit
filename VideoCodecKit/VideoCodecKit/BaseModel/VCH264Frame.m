//
//  VCH264Frame.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/9.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import "VCH264Frame.h"
#import "VCVideoFPS.h"

@implementation VCH264Frame
- (instancetype)init {
    self = [super init];
    if (self) {
        _frameIndex = 0;
    }
    return self;
}

- (instancetype)initWithWidth:(NSUInteger)width
                       height:(NSUInteger)height {
    self = [self init];
    if (self) {
        _width = width;
        _height = height;
    }
    return self;
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


+ (VCH264FrameType)getFrameType:(VCH264Frame *)frame {
    if (frame.parseData == nil || frame.parseSize < 4) {
        return VCH264FrameTypeUnknown;
    }
    
    static uint8_t startCodeType1[] = {0x00, 0x00, 0x00, 0x01};
    static uint8_t startCodeType2[] = {0x00, 0x00, 0x01};
    frame.startCodeSize = 0;
    if (memcmp(startCodeType1, frame.parseData, sizeof(startCodeType1)) == 0) {
        // start code type 00 00 00 01
        uint8_t naul_type = frame.parseData[4] & 0x1F;
        frame.startCodeSize = 4;
        return (VCH264FrameType)naul_type;
    }
    
    if (memcmp(startCodeType2, frame.parseData, sizeof(startCodeType2)) == 0) {
        // start code type 00 00 00 01
        uint8_t naul_type = frame.parseData[3] & 0x1F;
        frame.startCodeSize = 3;
        return (VCH264FrameType)naul_type;
    }
    
    return VCH264FrameTypeUnknown;
}

@end
