//
//  VCYUV422Image+FFmpeg.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/16.
//  Copyright © 2018年 eric3u. All rights reserved.
//
#import <libavcodec/avcodec.h>

#import "VCYUV422Image+FFmpeg.h"

@implementation VCYUV422Image (FFmpeg)
+ (instancetype)imageWithAVFrame:(AVFrame *)aFrame {
    VCYUV422Image *image = [[VCYUV422Image alloc] initWithWidth:aFrame->width height:aFrame->height];
    
    return image;
}
@end
