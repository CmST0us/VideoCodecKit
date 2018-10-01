//
//  VCH264Frame+FFmpeg.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/9.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import "VCH264Frame+FFmpeg.h"

@implementation VCH264Frame (FFmpeg)
+ (instancetype)h264FrameWithAVPacket:(AVPacket *)aPacket
                        parserContext:(AVCodecParserContext *)parserContext
                         codecContext:(AVCodecContext *)codecContext {
    
    VCH264Frame *frame = [[VCH264Frame alloc] initWithWidth:parserContext->width height:parserContext->height];
    
    frame.context = codecContext;
    [frame createParseDataWithSize:aPacket->size];
    memcpy(frame.parseData, aPacket->data, frame.parseSize);

    frame.frameIndex = parserContext->output_picture_number;
    frame.pts = parserContext->pts;
    frame.dts = parserContext->dts;
    
    if (parserContext->key_frame) {
        frame.isKeyFrame = YES;
    }
    
    return frame;
}
@end
