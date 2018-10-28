//
//  VCH264Frame.h
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/9.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VCBaseFrame.h"

typedef NS_ENUM(NSUInteger, VCH264FrameType) {
    VCH264FrameTypeUnknown = 0,
    VCH264FrameTypeSlice = 1,
    VCH264FrameTypeIDR = 5,
    VCH264FrameTypeSEI = 6,
    VCH264FrameTypeSPS = 7,
    VCH264FrameTypePPS = 8,
};

@interface VCH264Frame : VCBaseFrame

@property (nonatomic, assign) VCH264FrameType frameType;
@property (nonatomic, assign) NSUInteger frameIndex;
@property (nonatomic, assign) BOOL isKeyFrame;

@property (nonatomic, assign) int64_t pts;
@property (nonatomic, assign) int64_t dts;

@property (nonatomic, assign) NSInteger startCodeSize;

+ (VCH264FrameType)getFrameType:(VCH264Frame *)frame;

@end
