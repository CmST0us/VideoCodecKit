//
//  VCH264FFmpegFrameParser.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/9.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <libavcodec/avcodec.h>
#import <libavutil/avutil.h>

#import "VCH264FFmpegFrameParser.h"
#import "VCH264FFmpegFrameParserBuffer.h"
#import "VCH264Frame+FFmpeg.h"

@interface VCH264FFmpegFrameParser () {
    AVCodecContext *_codecContext;
    AVCodecParserContext *_parserContext;
    AVCodec *_codec;
    AVPacket *_packet;
}
@property (nonatomic, strong) NSLock *parserLock;

@end

@implementation VCH264FFmpegFrameParser

- (instancetype)init {
    self = [super init];
    if (self) {
        _parserLock = [[NSLock alloc] init];
        avcodec_register_all();
        [self commonInit];
    }
    return self;
}

#pragma mark - Private Method
- (void)commonInit {
    [self.parserLock lock];
    
    _packet = av_packet_alloc();
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
    
    if (_packet != nil) {
        av_packet_free(&_packet);
    }
    
    [self.parserLock unlock];
}

#pragma mark - Public Method

- (void)reset {
    [self free];
    [self commonInit];
}

- (id<VCFrameTypeProtocol>)parseData:(uint8_t *)buffer
                              length:(NSInteger)length
                          usedLength:(NSInteger *)usedLength
                            copyData:(BOOL)shouldCopy {
    if (_codecContext == nil && _parserContext == nil) {
        return nil;
    }
    
    [self.parserLock lock];
    
    NSInteger bufferLength = length;
    NSInteger parserLength = 0;
    VCH264Frame *outputFrame = nil;
    VCH264FFmpegFrameParserBuffer *parserBuffer = [[VCH264FFmpegFrameParserBuffer alloc] initWithBuffer:buffer length:length copyData:shouldCopy];
    
    while (bufferLength > 0) {
        
        parserLength = av_parser_parse2(_parserContext,
                                        _codecContext,
                                        &_packet->data,
                                        &_packet->size,
                                        parserBuffer.data,
                                        (int)parserBuffer.length,
                                        AV_NOPTS_VALUE,
                                        AV_NOPTS_VALUE,
                                        0);
        
        if (parserLength > bufferLength) {
            // 解码失败的 break
            break;
        }
        parserBuffer = [parserBuffer advancedBy:parserLength];
        bufferLength -= parserLength;
        
        if (usedLength) {
            *usedLength += parserLength;
        }
        
        if (_packet->size > 0) {
            
            outputFrame = [VCH264Frame h264FrameWithAVPacket:_packet parserContext:_parserContext];
            if (outputFrame != nil) {
                if (self.useDelegate && self.delegate != nil && [self.delegate respondsToSelector:@selector(frameParserDidParseFrame:)]) {
                    [self.delegate frameParserDidParseFrame:outputFrame];
                }
                self.currentParseFrame = outputFrame;
                self.pasrseCount += 1;
                break;
            }
            
        }
    }
    
    [self.parserLock unlock];
    return outputFrame;
}

- (NSInteger)parseData:(void *)buffer
                length:(NSInteger)length
              copyData:(BOOL)shouldCopy {
    
    if (_codecContext == nil && _parserContext == nil) {
        return -1;
    }
    
    [self.parserLock lock];
    
    NSInteger bufferLength = length;
    NSUInteger usedLength = 0;
    
    VCH264FFmpegFrameParserBuffer *buf = [[VCH264FFmpegFrameParserBuffer alloc] initWithBuffer:buffer length:length copyData:shouldCopy];
    
    while (bufferLength > 0) {
        
        int parserLen = av_parser_parse2(_parserContext,
                                         _codecContext,
                                         &_packet->data,
                                         &_packet->size,
                                         buf.data,
                                         (int)buf.length,
                                         AV_NOPTS_VALUE,
                                         AV_NOPTS_VALUE,
                                         0);
        if (parserLen > bufferLength) {
            // 解码失败的 break
            break;
        }
        
        buf = [buf advancedBy:parserLen];
        bufferLength -= parserLen;
        
        usedLength += parserLen;
        
        if (_packet->size > 0) {
            
            self.currentParseFrame = [VCH264Frame h264FrameWithAVPacket:_packet parserContext:_parserContext];
            
            self.pasrseCount += 1;
            if (self.useDelegate && [self.delegate respondsToSelector:@selector(frameParserDidParseFrame:)]) {
                [self.delegate frameParserDidParseFrame:self.currentParseFrame];
            }
            
        }
    }
    
    [self.parserLock unlock];
    
    return usedLength;
}

- (NSInteger)parseData:(void *)buffer
                length:(NSInteger)length
              copyData:(BOOL)shouldCopy
            completion:(void (^)(id<VCFrameTypeProtocol> _Nonnull))block {
    
    if (_codecContext == nil && _parserContext == nil) {
        return -1;
    }
    
    [self.parserLock lock];
    
    NSInteger bufferLength = length;
    NSUInteger usedLength = 0;
    
    VCH264FFmpegFrameParserBuffer *buf = [[VCH264FFmpegFrameParserBuffer alloc] initWithBuffer:buffer length:length copyData:shouldCopy];
    
    while (bufferLength > 0) {
        
        int parserLen = av_parser_parse2(_parserContext,
                                         _codecContext,
                                         &_packet->data,
                                         &_packet->size,
                                         buf.data,
                                         (int)buf.length,
                                         AV_NOPTS_VALUE,
                                         AV_NOPTS_VALUE,
                                         0);
        if (parserLen > bufferLength) {
            // 解码失败的 break
            break;
        }
        
        buf = [buf advancedBy:parserLen];
        bufferLength -= parserLen;
        
        usedLength += parserLen;
        
        if (_packet->size > 0) {
            
            VCH264Frame *frame = [VCH264Frame h264FrameWithAVPacket:_packet parserContext:_parserContext];
            self.currentParseFrame = frame;
            
            self.pasrseCount += 1;
            if (block) {
                block(frame);
            }
        }
    }
    
    [self.parserLock unlock];
    
    return usedLength;
}

- (void)dealloc{
    [self free];
}
@end
