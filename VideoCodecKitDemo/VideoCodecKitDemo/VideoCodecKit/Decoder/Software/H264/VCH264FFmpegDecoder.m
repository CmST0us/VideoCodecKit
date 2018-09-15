//
//  VCH264FFmpegDecoder.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/9.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <libavcodec/avcodec.h>
#import <libavutil/avutil.h>

#import "VCH264FFmpegDecoder.h"
#import "VCH264Frame.h"

@interface VCH264FFmpegDecoder () {
    AVFrame *_frame;
}

@end

@implementation VCH264FFmpegDecoder

- (void)setup {
    
}

- (void)run {
    
}

- (void)pause {
    
}

- (void)resume {
    
}

- (void)invalidate {
    
}

- (void)decodeFrame:(id<VCFrameTypeProtocol>)frame
         completion:(void (^)(id<VCFrameTypeProtocol> _Nonnull))block {
    // read frame parse
    if (![self isH264Frame:frame]) {
        
        return;
    }
    
    
}

- (BOOL)isH264Frame:(id<VCFrameTypeProtocol>)frame {
    if ([frame.frameClassString isEqualToString:NSStringFromClass([VCH264Frame class])]) {
        return YES;
    }
    return NO;
}
@end
