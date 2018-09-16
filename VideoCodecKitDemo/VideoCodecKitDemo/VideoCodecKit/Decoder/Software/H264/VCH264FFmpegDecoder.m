//
//  VCH264FFmpegDecoder.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/9.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <libavcodec/avcodec.h>
#import <libavutil/avutil.h>
#import <pthread.h>

#import "VCH264FFMpegFrameParser.h"
#import "VCH264FFmpegDecoder.h"
#import "VCH264Frame.h"
#import "VCYUV420PImage+FFmpeg.h"

@interface VCH264FFmpegDecoder () {
    AVFrame *_frame;
    pthread_mutex_t _decodeLock;
}

@end

@implementation VCH264FFmpegDecoder

- (instancetype)init {
    self = [super init];
    if (self) {
        pthread_mutex_init(&_decodeLock, NULL);
    }
    return self;
}

- (void)dealloc {
    pthread_mutex_destroy(&_decodeLock);
}

- (void)setup {
    _frame = av_frame_alloc();;
    _parser = [[VCH264FFmpegFrameParser alloc] init];;
    
    [self commitStateTransition];
}


- (void)invalidate {
    av_frame_free(&_frame);
    _frame = nil;
    [_parser reset];
    [self commitStateTransition];
}

- (void)decodeFrame:(id<VCFrameTypeProtocol>)frame
         completion:(void (^)(id<VCFrameTypeProtocol> _Nonnull frame))block {
    if (self.currentState.unsignedIntegerValue != VCBaseDecoderStateRunning) return;

    // read frame parse
    if (![self isH264Frame:frame]) {
        return;
    }
    
    pthread_mutex_lock(&_decodeLock);
    VCH264Frame *h264Frame = (VCH264Frame *)frame;
    AVPacket *packet = av_packet_alloc();
    
    packet->data = h264Frame.parseData;
    packet->size = (int)h264Frame.parseSize;
    
    avcodec_send_packet(self.parser.codecContext, packet);
    int got_picture = avcodec_receive_frame(self.parser.codecContext, _frame);
    if (got_picture == 0) {
        VCYUV420PImage *image = [VCYUV420PImage imageWithAVFrame:_frame];
        h264Frame.sliceType = (VCH264SliceType)_frame->pict_type;
        h264Frame.image = image;
        if (block) {
            block(h264Frame);
        }
    }
    
    av_packet_free(&packet);
    pthread_mutex_unlock(&_decodeLock);
}

- (BOOL)isH264Frame:(id<VCFrameTypeProtocol>)frame {
    if ([frame.frameClassString isEqualToString:NSStringFromClass([VCH264Frame class])]) {
        return YES;
    }
    return NO;
}
@end
