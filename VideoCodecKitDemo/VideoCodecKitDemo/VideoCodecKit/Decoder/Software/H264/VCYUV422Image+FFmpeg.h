//
//  VCYUV422Image+FFmpeg.h
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/16.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import "VCYUV422Image.h"

@interface VCYUV422Image (FFmpeg)
+ (instancetype)imageWithAVFrame:(AVFrame *)aFrame;
@end
