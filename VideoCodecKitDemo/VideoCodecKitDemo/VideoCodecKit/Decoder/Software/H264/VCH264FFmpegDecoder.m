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
#import "VCH264Image+FFmpeg.h"

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
    [self commitStateTransition];
}


- (void)invalidate {
    av_frame_free(&_frame);
    _frame = nil;
    [self commitStateTransition];
}

- (void)decodeFrame:(id<VCFrameTypeProtocol>)frame
         completion:(void (^)(id<VCImageTypeProtocol> image))block {
    id<VCImageTypeProtocol> decodeImage = [self decode:frame];
    if (block) {
        block(decodeImage);
    }
}

- (id<VCImageTypeProtocol>)decode:(id<VCFrameTypeProtocol>)frame {
    if (self.currentState.unsignedIntegerValue != VCBaseDecoderStateRunning) return nil;

    // read frame parse
    if (![VCH264FFmpegDecoder isH264Frame:frame]) {
        return nil;
    }
    
    pthread_mutex_lock(&_decodeLock);
    VCH264Frame *h264Frame = (VCH264Frame *)frame;
    VCH264Image *image = nil;
    AVPacket *packet = av_packet_alloc();
    
    packet->data = h264Frame.parseData;
    packet->size = (int)h264Frame.parseSize;
    
    avcodec_send_packet(frame.context, packet);
    int got_picture = avcodec_receive_frame(frame.context, _frame);
    if (got_picture == 0) {
        image = [VCH264Image imageWithAVFrame:_frame];
    }
    
    av_packet_free(&packet);
    pthread_mutex_unlock(&_decodeLock);
    return image;
}

- (void)decodeWithFrame:(id<VCFrameTypeProtocol>)frame {
    id<VCImageTypeProtocol> decodeImage = [self decode:frame];
    if (self.delegate && [self.delegate respondsToSelector:@selector(decoder:didProcessImage:)]) {
        if (decodeImage != nil) {
            [self.delegate decoder:self didProcessImage:decodeImage];
        }
    }
}


+ (BOOL)isH264Frame:(id<VCFrameTypeProtocol>)frame {
    if ([frame.frameClassString isEqualToString:NSStringFromClass([VCH264Frame class])]) {
        return YES;
    }
    return NO;
}

@end
