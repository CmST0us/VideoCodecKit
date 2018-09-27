//
//  VCH264Image+FFmpeg.h
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/16.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import "VCH264Image.h"

@interface VCH264Image (FFmpeg)
+ (instancetype)imageWithAVFrame:(AVFrame *)aFrame;
@end
