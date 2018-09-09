//
//  VCH264FFMpegDecoder.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/9.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <libavcodec/avcodec.h>
#import <libavutil/avutil.h>

#import "VCH264FFmpegDecoder.h"

@interface VCH264FFMpegDecoder () {
    AVFrame *_frame;
}

@end

@implementation VCH264FFMpegDecoder
- (BOOL)start {
    if (![super start]) {
        return NO;
    }
    
    return YES;
}

- (BOOL)stop {
    if (![super stop]) {
        return NO;
    }
    
    return YES;
}

- (BOOL)pause {
    if (![super pause]) {
        return NO;
    }
    
    return YES;
}

- (BOOL)resume {
    if (![super resume]) {
        return NO;
    }
    
    return YES;
}

- (BOOL)reset {
    if (![super reset]) {
        return NO;
    }
    
    return YES;
}

@end
