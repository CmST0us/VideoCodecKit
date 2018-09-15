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
    VCH264Frame *frame = [[VCH264Frame alloc] initWithWidth:parserContext->width height:parserContext->height bytesPerRow:parserContext->width * 8];
    [frame createParseDaraWithSize:aPacket->size];
    memcpy(frame.parseData, aPacket->data, frame.parseSize);
    
    frame.frameIndex = parserContext->output_picture_number;
    if (parserContext->key_frame) {
        frame.frameType = VCH264FrameTypeIDR;
    }
    
    return frame;
}
@end
