//
//  VCYUV420PImage+FFmpeg.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/16.
//  Copyright © 2018年 eric3u. All rights reserved.
//
#import <libavcodec/avcodec.h>

#import "VCYUV420PImage+FFmpeg.h"

@implementation VCYUV420PImage (FFmpeg)

+ (instancetype)imageWithAVFrame:(AVFrame *)aFrame {
    // 检查色彩空间
    if (aFrame->format != AV_PIX_FMT_YUV420P && aFrame->format != AV_PIX_FMT_YUVJ420P) {
        return nil;
    }
    
    VCYUV420PImage *image = [[VCYUV420PImage alloc] initWithWidth:aFrame->width height:aFrame->height];
    
    [image createLumaDataWithSize:image.height * aFrame->linesize[0] AndLineSize:aFrame->linesize[0]];
    [image createChromaBDataWithSize:image.height * aFrame->linesize[1] / 2 AndLineSize:aFrame->linesize[1]];
    [image createChromaRDataWithSize:image.height * aFrame->linesize[2] / 2 AndLineSize:aFrame->linesize[2]];
    
    memcpy(image.luma, aFrame->data[0], aFrame->linesize[0] * aFrame->height);
    memcpy(image.chromaB, aFrame->data[1], aFrame->linesize[1] * aFrame->height / 2);
    memcpy(image.chromaR, aFrame->data[2], aFrame->linesize[2] * aFrame->height / 2);
    
    return image;
}
@end
