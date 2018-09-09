//
//  VCH264FFMpegFrameParser.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/9.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <libavcodec/avcodec.h>
#import <libavutil/avutil.h>

#import "VCH264FFMpegFrameParser.h"
#import "VCH264FFmpegFrameParserBuffer.h"
#import "VCH264Frame+FFmpeg.h"

@interface VCH264FFMpegFrameParser () {
    AVCodecContext *_codecContext;
    AVCodecParserContext *_parserContext;
    AVCodec *_codec;
}
@property (nonatomic, strong) NSLock *parserLock;

@end

@implementation VCH264FFMpegFrameParser

- (instancetype)init {
    self = [super init];
    if (self) {
        _parserLock = [[NSLock alloc] init];
    }
    return self;
}

#pragma mark - Private Method
- (void)commonInit {
    [self.parserLock lock];
    
    _codec = avcodec_find_decoder(AV_CODEC_ID_H264);
    NSAssert(_codec != nil, @"Can not find ffmpeg h264 decoder");
    
    _parserContext = av_parser_init(_codec->id);
    _codecContext = avcodec_alloc_context3(_codec);
    
    [self.parserLock unlock];
}

- (void)free {
    [self.parserLock lock];
    
    if (_codecContext != nil) {
        avcodec_close(_codecContext);
        av_freep(&_codecContext);
    }
    if (_parserContext != nil) {
        av_parser_close(_parserContext);
        av_freep(&_codecContext);
    }
    
    [self.parserLock unlock];
}

#pragma mark - Public Method

- (void)reset {
    [self free];
    [self commonInit];
}

- (NSInteger)parseData:(void *)buffer
                length:(NSUInteger)length {
    if (_codecContext == nil && _parserContext == nil) {
        return -1;
    }
    
    [self.parserLock lock];
    
    NSUInteger bufferLength = length;
    NSUInteger usedLength = 0;
    
    VCH264FFmpegFrameParserBuffer *buf = [[VCH264FFmpegFrameParserBuffer alloc] initWithBuffer:buffer length:length copyData:YES];
    
    AVPacket *packet = av_packet_alloc();
    
    while (bufferLength > 0) {
        
        int parserLen = av_parser_parse2(_parserContext, _codecContext, &packet->data, &packet->size, buf.data, (int)bufferLength, AV_NOPTS_VALUE, AV_NOPTS_VALUE, 0);
        
        bufferLength -= parserLen;
        buf = [buf advancedBy:parserLen];
        
        usedLength += parserLen;
        
        if (packet->size > 0) {
            
            VCH264Frame *h264Frame = [VCH264Frame h264FrameWithAVPacket:packet parserContext:_parserContext];
            
            if ([self.delegate respondsToSelector:@selector(frameParserDidParseFrame:)]) {
                [self.delegate frameParserDidParseFrame:h264Frame];
            }
        }
    }
    
    av_packet_free(&packet);
    [self.parserLock unlock];
    
    return usedLength;
}
@end
