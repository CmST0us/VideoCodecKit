//
//  VCAnnexBFormatParser.m
//  VideoCodecKit
//
//  Created by CmST0us on 2019/1/28.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "VCAnnexBFormatParser.h"
#import "VCAnnexBFormatStream.h"

#define kVCAnnexBFormatParserDefaultBufferCapacity 4096

//                            +-----+
//                            |     |
//                            v     |
// 7--(0)-->2--(0)-->1--(0)-->0-(0)-+
// ^        |        |        |
// |       (1)      (1)      (1)
// |        |        |        |
// +--------+        v        v
//                   4        5


typedef NS_ENUM(NSUInteger, VCAnnexBFormatParserState) {
    VCAnnexBFormatParserStateInit = 7,
    VCAnnexBFormatParserStateFind1Zero = 2,
    VCAnnexBFormatParserStateFind2Zero = 1,
    VCAnnexBFormatParserStateFindMoreThan2Zero = 0,
    VCAnnexBFormatParserStateFind2ZeroAnd1One = 4,
    VCAnnexBFormatParserStateFindMoreThan2ZeroAnd1One = 5,
};

@interface VCAnnexBFormatParser ()
// parse 缓冲区
@property (nonatomic, strong) NSMutableData *parsingBuffer;
// 最后一个 分隔符 之后的数据加到 appendingBuffer中，
// 和parsingBuffer在appendData方法中合并
@property (nonatomic, strong) NSMutableData *appendingBuffer;

// 解析位置
@property (nonatomic, assign) NSInteger position;
@property (nonatomic, assign) NSInteger nextFramePosition;
@end

@implementation VCAnnexBFormatParser

- (instancetype)init {
    self = [super init];
    if (self) {
        _parsingBuffer = [[NSMutableData alloc] initWithCapacity:kVCAnnexBFormatParserDefaultBufferCapacity];
        _appendingBuffer = [[NSMutableData alloc] initWithCapacity:kVCAnnexBFormatParserDefaultBufferCapacity];
    }
    return self;
}

- (VCAnnexBFormatStream *)next {
    NSMutableData *outputData = [[NSMutableData alloc] initWithCapacity:self.parsingBuffer.length];
    NSMutableData *payloadData = [[NSMutableData alloc] initWithCapacity:self.parsingBuffer.length];
    
    VCAnnexBFormatParserState state = VCAnnexBFormatParserStateInit;
    static uint8_t reserveStartCode[4] = {0x00, 0x00, 0x00, 0x01};
    
    uint8_t *ptr = (uint8_t *)[self.parsingBuffer bytes];
    
    for (; _position < self.parsingBuffer.length; ++_position) {
        uint8_t byte = *(ptr + _position);
        // alsosee: ffmpeg h264_find_frame_end()
        
        if (state == VCAnnexBFormatParserStateInit) {
            if (byte == 0) {
                state = VCAnnexBFormatParserStateFind1Zero;
            }
        } else if (state <= VCAnnexBFormatParserStateFind1Zero) {
            // 找到0的时候
            if (byte == 1) {
                // 发现一个1
                state ^= VCAnnexBFormatParserStateFindMoreThan2ZeroAnd1One;
            } else if (byte) {
                state = VCAnnexBFormatParserStateInit;
            } else {
                state >>= 1; // 发现一个0
            }
        } else if (state <= VCAnnexBFormatParserStateFindMoreThan2ZeroAnd1One) {
            _nextFramePosition = _position;
            if (state == VCAnnexBFormatParserStateFind2ZeroAnd1One) {
                // 找到 00 00 01
                if (payloadData.length > 3) {
                    [outputData appendBytes:reserveStartCode length:4];
                    [outputData appendData:[payloadData subdataWithRange:NSMakeRange(0, payloadData.length - 3)]];
                    payloadData = [[NSMutableData alloc] initWithCapacity:self.parsingBuffer.length];
                    
                    VCAnnexBFormatStream *data = [[VCAnnexBFormatStream alloc] initWithData:outputData];
                    return data;
                }
            } else if (state == VCAnnexBFormatParserStateFindMoreThan2ZeroAnd1One) {
                // 找到 00 00 00 01
                if (payloadData.length > 4) {
                    [outputData appendBytes:reserveStartCode length:4];
                    [outputData appendData:[payloadData subdataWithRange:NSMakeRange(0, payloadData.length - 4)]];
                    payloadData = [[NSMutableData alloc] initWithCapacity:self.parsingBuffer.length];
                    
                    VCAnnexBFormatStream *data = [[VCAnnexBFormatStream alloc] initWithData:outputData];
                    return data;
                }
            }
            state = VCAnnexBFormatParserStateInit;
        } else {
            // TODO
            
        }
        
        if (_position >= _nextFramePosition) {
            // read data
            [payloadData appendBytes:&byte length:1];
        }
    }
    
    if (payloadData.length > 0) {
        // 末尾数据
        [outputData appendBytes:reserveStartCode length:4];
        [outputData appendData:payloadData];
        _appendingBuffer = outputData;
    }
    
    return nil;
}

- (void)appendData:(NSData *)data {
    _parsingBuffer = [[NSMutableData alloc] initWithCapacity:_appendingBuffer.length + data.length];
    if ([self.appendingBuffer length] > 0) {
        [_parsingBuffer appendData:_appendingBuffer];
        _appendingBuffer = [[NSMutableData alloc] initWithCapacity:kVCAnnexBFormatParserDefaultBufferCapacity];
    }
    [_parsingBuffer appendData:data];
    _position = 0;
    _nextFramePosition = _parsingBuffer.length;
}

@end
