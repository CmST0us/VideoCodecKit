//
//  VCH264FrameParser.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/9.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import "VCH264FrameParser.h"

@implementation VCH264FrameParser

+ (VCH264FrameType)getFrameType:(VCH264Frame *)frame {
    if (frame.parseData == nil || frame.parseSize < 4) {
        return VCH264FrameTypeUnknown;
    }
    
    static uint8_t startCodeType1[] = {0x00, 0x00, 0x00, 0x01};
    static uint8_t startCodeType2[] = {0x00, 0x00, 0x01};
    
    if (memcmp(startCodeType1, frame.parseData, sizeof(startCodeType1)) == 0) {
        // start code type 00 00 00 01
        uint8_t naul_type = frame.parseData[4] & 0x1F;
        return (VCH264FrameType)naul_type;
    }
    
    if (memcmp(startCodeType2, frame.parseData, sizeof(startCodeType2)) == 0) {
        // start code type 00 00 00 01
        uint8_t naul_type = frame.parseData[3] & 0x1F;
        return (VCH264FrameType)naul_type;
    }
    
    return VCH264FrameTypeUnknown;
}

@end
