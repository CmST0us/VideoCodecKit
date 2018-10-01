//
//  VCH264Frame.h
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/9.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VCFrameTypeProtocol.h"
#import "VCH264Image.h"

typedef NS_ENUM(NSUInteger, VCH264FrameType) {
    VCH264FrameTypeUnknown = 0,
    VCH264FrameTypeSlice = 1,
    VCH264FrameTypeIDR = 5,
    VCH264FrameTypeSEI = 6,
    VCH264FrameTypeSPS = 7,
    VCH264FrameTypePPS = 8,
};

@class VCVideoFPS;
@interface VCH264Frame : NSObject<VCFrameTypeProtocol>

@property (nonatomic, assign) VCH264FrameType frameType;
@property (nonatomic, assign) NSUInteger frameIndex;
@property (nonatomic, assign) BOOL isKeyFrame;

@property (nonatomic, assign) NSUInteger width;
@property (nonatomic, assign) NSUInteger height;
@property (nonatomic, strong) VCVideoFPS *fps;

@property (nonatomic, assign) int64_t pts;
@property (nonatomic, assign) int64_t dts;

@property (nonatomic, assign) uint8_t *parseData;
@property (nonatomic, assign) NSUInteger parseSize;
@property (nonatomic, assign) NSInteger startCodeSize;

@property (nonatomic, assign) void *context;
- (instancetype)initWithWidth:(NSUInteger)width
                       height:(NSUInteger)height;

- (void)createParseDataWithSize:(NSUInteger)size;
@end
