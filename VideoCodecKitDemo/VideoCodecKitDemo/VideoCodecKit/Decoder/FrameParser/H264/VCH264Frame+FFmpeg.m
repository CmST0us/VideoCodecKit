//
//  VCH264Frame+FFmpeg.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/9.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import "VCH264Frame+FFmpeg.h"

@implementation VCH264Frame (FFmpeg)
+ (instancetype)h264FrameWithAVPacket:(AVPacket *)aPacket parserContext:(AVCodecParserContext *)parserContext {
    VCH264Frame *frame = [[VCH264Frame alloc] init];
    frame.parserData = aPacket->data;
    frame.pasrserSize = aPacket->size;
    frame.width = parserContext->width;
    frame.height = parserContext->height;
    frame.frameIndex = parserContext->output_picture_number;
    frame.isIDR = parserContext->key_frame == 1;
    return frame;
}
@end
