//
//  VCH264Frame+FFmpeg.h
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/9.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <libavcodec/avcodec.h>

#import "VCH264Frame.h"

@interface VCH264Frame (FFmpeg)

+ (instancetype)h264FrameWithAVPacket:(AVPacket *)aPacket
                        parserContext:(AVCodecParserContext *)parserContext;

@end
