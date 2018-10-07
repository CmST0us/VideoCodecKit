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
#import "VCH264SPSFrame.h"

@interface VCH264FFmpegFrameParser () {
    AVCodecContext *_codecContext;
    AVCodecParserContext *_parserContext;
    AVCodec *_codec;
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
    
    _codec = avcodec_find_decoder(AV_CODEC_ID_H264);
    NSAssert(_codec != nil, @"Can not find ffmpeg h264 decoder");
    
    _parserContext = av_parser_init(_codec->id);
    _codecContext = avcodec_alloc_context3(_codec);
    if (avcodec_open2(_codecContext, _codec, NULL) < 0) {
        NSAssert(false, @"Can not open codec");
    }
    
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

- (id<VCFrameTypeProtocol>)parseData:(uint8_t *)buffer
                              length:(NSInteger)length
                          usedLength:(NSInteger *)usedLength {
    if (_codecContext == nil && _parserContext == nil) {
        return nil;
    }
    
    [self.parserLock lock];
    
    NSInteger bufferLength = length;
    NSInteger parserLength = 0;
    VCH264Frame *outputFrame = nil;
    VCH264FFmpegFrameParserBuffer *parserBuffer = [[VCH264FFmpegFrameParserBuffer alloc] initWithBuffer:buffer length:length copyData:NO];
    
    while (bufferLength > 0) {
        AVPacket *packet = av_packet_alloc();
        
        parserLength = av_parser_parse2(_parserContext,
                                        _codecContext,
                                        &packet->data,
                                        &packet->size,
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
        
        if (packet->size > 0) {
            
            outputFrame = [VCH264Frame h264FrameWithAVPacket:packet parserContext:_parserContext codecContext:_codecContext];
            outputFrame.frameType = [VCH264FrameParser getFrameType:outputFrame];
            if (outputFrame != nil) {
                if (self.useDelegate && self.delegate != nil && [self.delegate respondsToSelector:@selector(frameParserDidParseFrame:)]) {
                    [self.delegate frameParserDidParseFrame:outputFrame];
                }
                self.pasrseCount += 1;
                
                av_packet_free(&packet);
                break;
            }
        }
        
        if (packet != NULL) {
            av_packet_free(&packet);
        }
    }
    
    [self.parserLock unlock];
    return outputFrame;
}

- (NSInteger)parseData:(void *)buffer
                length:(NSInteger)length {
    
    if (_codecContext == nil && _parserContext == nil) {
        return -1;
    }
    
    [self.parserLock lock];
    
    NSInteger bufferLength = length;
    NSUInteger usedLength = 0;
    
    VCH264FFmpegFrameParserBuffer *buf = [[VCH264FFmpegFrameParserBuffer alloc] initWithBuffer:buffer length:length copyData:NO];
    
    while (bufferLength > 0) {
        AVPacket *packet = av_packet_alloc();
        int parserLen = av_parser_parse2(_parserContext,
                                         _codecContext,
                                         &packet->data,
                                         &packet->size,
                                         buf.data,
                                         (int)buf.length,
                                         AV_NOPTS_VALUE,
                                         AV_NOPTS_VALUE,
                                         0);
        if (parserLen > bufferLength) {
            // 解码失败的 break
            if (packet != NULL) {
                av_packet_free(&packet);
            }
            break;
        }
        
        buf = [buf advancedBy:parserLen];
        bufferLength -= parserLen;
        
        usedLength += parserLen;
        
        if (packet->size > 0) {
            // ffmpeg 对于关键帧 会把所有信息推一次，手动解一下
            VCH264Frame *frame = [VCH264Frame h264FrameWithAVPacket:packet parserContext:_parserContext codecContext:_codecContext];
            frame.frameType = [VCH264FrameParser getFrameType:frame];
            
            if (frame.isKeyFrame) {
                NSMutableDictionary *offsetDict = [NSMutableDictionary dictionary];
                NSInteger lastIndex = 0;
                for (NSInteger i = frame.startCodeSize; i < frame.parseSize - 4; i++) {
                    
                    static uint8_t startCode1[4] = {0x00, 0x00, 0x00, 0x01};
                    static uint8_t startCode2[3] = {0x00, 0x00, 0x01};
                    
                    if (memcmp(frame.parseData + i, startCode1, sizeof(startCode1)) == 0) {
                        offsetDict[@(lastIndex)] = @(i - lastIndex);
                        lastIndex = i;
                        i += 3;
                    }
                    
                    if(memcmp(frame.parseData + i, startCode2, sizeof(startCode2)) == 0) {
                        offsetDict[@(lastIndex)] = @(i - lastIndex);
                        lastIndex = i;
                        i += 3;
                    }
                    
                }
                
                if (lastIndex < frame.parseSize) {
                    offsetDict[@(lastIndex)] = @(frame.parseSize - lastIndex);
                }
                
                NSArray *sortOffsetKeys = [offsetDict.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                    if ([obj1 integerValue] > [obj2 integerValue]) return NSOrderedDescending;
                    if ([obj1 integerValue] < [obj2 integerValue]) return NSOrderedAscending;
                    return NSOrderedSame;
                }];
                
                for (NSNumber *offset in sortOffsetKeys) {
                    NSNumber *size = offsetDict[offset];
                    VCH264Frame *f = [[VCH264Frame alloc] initWithWidth:frame.width height:frame.height];
                    [f createParseDataWithSize:size.integerValue];
                    memcpy(f.parseData, frame.parseData + offset.integerValue, size.integerValue);
                    
                    f.frameType = [VCH264FrameParser getFrameType:f];
                    // check if frame is sps
                    if (f.frameType == VCH264FrameTypeSPS) {
                        f = [[VCH264SPSFrame alloc] initWithWidth:frame.width height:frame.height];
                        [f createParseDataWithSize:size.integerValue];
                        memcpy(f.parseData, frame.parseData + offset.integerValue, size.integerValue);
                        f.frameType = [VCH264FrameParser getFrameType:f];
                    }
                    
                    f.context = frame.context;
                    f.frameIndex = _parserContext->output_picture_number;
                    f.pts = _parserContext->pts;
                    f.dts = _parserContext->dts;
                    
                    if (self.useDelegate && [self.delegate respondsToSelector:@selector(frameParserDidParseFrame:)]) {
                        [self.delegate frameParserDidParseFrame:f];
                    }
                    
                }
            } else {
                
                if (self.useDelegate && [self.delegate respondsToSelector:@selector(frameParserDidParseFrame:)]) {
                    [self.delegate frameParserDidParseFrame:frame];
                }
            }
            
            self.pasrseCount += 1;
        }
        if (packet != NULL) {
            av_packet_free(&packet);
        }
    }
    
    [self.parserLock unlock];
    
    return usedLength;
}

- (NSInteger)parseData:(void *)buffer
                length:(NSInteger)length
            completion:(void (^)(id<VCFrameTypeProtocol> _Nonnull frame))block {
    
    if (_codecContext == nil && _parserContext == nil) {
        return -1;
    }
    
    [self.parserLock lock];
    
    NSInteger bufferLength = length;
    NSUInteger usedLength = 0;
    
    VCH264FFmpegFrameParserBuffer *buf = [[VCH264FFmpegFrameParserBuffer alloc] initWithBuffer:buffer length:length copyData:NO];
    
    while (bufferLength > 0) {
        AVPacket *packet = av_packet_alloc();
        
        int parserLen = av_parser_parse2(_parserContext,
                                         _codecContext,
                                         &packet->data,
                                         &packet->size,
                                         buf.data,
                                         (int)buf.length,
                                         AV_NOPTS_VALUE,
                                         AV_NOPTS_VALUE,
                                         0);
        if (parserLen > bufferLength) {
            // 解码失败的 break
            if (packet != NULL) {
                av_packet_free(&packet);
            }
            break;
        }
        
        buf = [buf advancedBy:parserLen];
        bufferLength -= parserLen;
        
        usedLength += parserLen;
        
        if (packet->size > 0) {
            VCH264Frame *frame = [VCH264Frame h264FrameWithAVPacket:packet parserContext:_parserContext codecContext:_codecContext];
            frame.frameType = [VCH264FrameParser getFrameType:frame];

            self.pasrseCount += 1;
            if (block) {
                block(frame);
            }
        }
        
        if (packet != NULL) {
            av_packet_free(&packet);
        }
    }
    
    [self.parserLock unlock];
    
    return usedLength;
}


- (void)dealloc{
    [self free];
}
@end
