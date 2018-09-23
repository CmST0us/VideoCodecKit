//
//  VCH264FFmpegDecoder.h
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/9.
//  Copyright © 2018年 eric3u. All rights reserved.
//


#import "VCBaseDecoder.h"

@interface VCH264FFmpegDecoder : VCBaseDecoder
+ (BOOL)isH264Frame:(id<VCFrameTypeProtocol>)frame;
    
@end
