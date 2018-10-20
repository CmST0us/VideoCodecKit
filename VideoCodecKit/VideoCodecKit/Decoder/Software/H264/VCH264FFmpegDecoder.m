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
#import "VCPriorityObjectQueue.h"
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
        _frame = av_frame_alloc();;
    }
    return self;
}

- (void)dealloc {
    if (_frame != NULL) {
        av_frame_free(&_frame);
        _frame = nil;
    }
    pthread_mutex_destroy(&_decodeLock);
}

- (void)decodeFrame:(VCBaseFrame *)frame
         completion:(void (^)(id<VCImageTypeProtocol> image))block {
    id<VCImageTypeProtocol> decodeImage = [self decode:frame];
    if (block) {
        block(decodeImage);
    }
}

- (id<VCImageTypeProtocol>)decode:(VCBaseFrame *)frame {
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
    
    NSValue *context = [frame.userInfo objectForKey:kVCBaseFrameUserInfoFFmpegAVCodecContextKey];
    AVCodecContext *codecContext = NULL;
    if (context != nil && [context isKindOfClass:[NSValue class]]) {
        codecContext = [context pointerValue];
    }
    if (codecContext != NULL && avcodec_is_open(codecContext)) {
        avcodec_send_packet(codecContext, packet);
    } else {
        pthread_mutex_unlock(&_decodeLock);
        return nil;
    }
    int got_picture = avcodec_receive_frame(codecContext, _frame);
    if (got_picture == 0) {
        image = [VCH264Image imageWithAVFrame:_frame];
        // ffmpeg 内部处理了
        image.priority = 0;
    }
    
    av_packet_free(&packet);
    pthread_mutex_unlock(&_decodeLock);
    return image;
}

- (void)decodeWithFrame:(VCBaseFrame *)frame {
    id<VCImageTypeProtocol> decodeImage = [self decode:frame];
    if (self.delegate && [self.delegate respondsToSelector:@selector(decoder:didProcessImage:)]) {
        if (decodeImage != nil) {
            [self.delegate decoder:self didProcessImage:decodeImage];
        }
    }
}


+ (BOOL)isH264Frame:(VCBaseFrame *)frame {
    if ([[frame class] isSubclassOfClass:[VCH264Frame class]]) {
        return YES;
    }
    return NO;
}

@end
