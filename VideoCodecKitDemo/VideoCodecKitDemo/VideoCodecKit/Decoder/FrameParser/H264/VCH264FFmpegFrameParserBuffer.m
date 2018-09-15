//
//  VCH264FFmpegFrameParserBuffer.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/9.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <libavcodec/avcodec.h>

#import "VCH264FFmpegFrameParserBuffer.h"

@implementation VCH264FFmpegFrameParserBuffer

- (instancetype)init {
    self = [super init];
    if (self) {
        _isCopyData = NO;
        _data = nil;
        _length = 0;
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data copyData:(BOOL *)isCopy {
    self = [super init];
    if (self) {
        _isCopyData = isCopy;
        
        if (_isCopyData) {
            _length = FF_INPUT_BUFFER_PADDING_SIZE + data.length;
            _data = malloc(_length);
            memset(((char *)_data) + data.length, 0, FF_INPUT_BUFFER_PADDING_SIZE);
            memcpy(_data, data.bytes, data.length);
        } else {
            _length = data.length;
            _data = (void *)data.bytes;
        }
    }
    return self;
}

- (instancetype)initWithBuffer:(void *)buffer length:(NSUInteger)length copyData:(BOOL)isCopy {
    self = [super init];
    if (self) {
        _isCopyData = isCopy;
        
        if (_isCopyData) {
            _length = FF_INPUT_BUFFER_PADDING_SIZE + length;
            _data = malloc(_length);
            memset(((char *)_data) + length, 0, FF_INPUT_BUFFER_PADDING_SIZE);
            memcpy(_data, buffer, length);
        } else {
            _length = length;
            _data = buffer;
        }
    }
    return self;
}

- (instancetype)advancedBy:(NSInteger)step {
    VCH264FFmpegFrameParserBuffer *buf = [[VCH264FFmpegFrameParserBuffer alloc] init];
    buf.data = self.data + step;
    buf.length = self.length - step;
    return buf;
}

- (void)dealloc {
    if (_isCopyData) {
        if (_data != nil) {
            free(_data);
        }
    }
}

@end
