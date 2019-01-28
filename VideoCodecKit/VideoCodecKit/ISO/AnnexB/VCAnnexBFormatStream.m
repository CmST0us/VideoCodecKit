//
//  VCAnnexBFormatStream.m
//  VideoCodecKit
//
//  Created by CmST0us on 2019/1/19.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "VCAnnexBFormatStream.h"
#import "VCAVCFormatStream.h"
#import "VCByteArray.h"


//                            +-----+
//                            |     |
//                            v     |
// 7--(0)-->2--(0)-->1--(0)-->0-(0)-+
// ^        |        |        |
// |       (1)      (1)      (1)
// |        |        |        |
// +--------+        v        v
//                   4        5


typedef NS_ENUM(NSUInteger, VCAnnexBFormatStreamParseState) {
    VCAnnexBFormatStreamParseStateInit = 7,
    VCAnnexBFormatStreamParseStateFind1Zero = 2,
    VCAnnexBFormatStreamParseStateFind2Zero = 1,
    VCAnnexBFormatStreamParseStateFindMoreThan2Zero = 0,
    VCAnnexBFormatStreamParseStateFind2ZeroAnd1One = 4,
    VCAnnexBFormatStreamParseStateFindMoreThan2ZeroAnd1One = 5,
};

@implementation VCAnnexBFormatStream

- (instancetype)initWithData:(NSData *)aData {
    self = [super init];
    if (self) {
        _data = aData;
    }
    return self;
}

- (VCAVCFormatStream *)toAVCFormatStream {
    NSMutableData *outputData = [[NSMutableData alloc] initWithCapacity:_data.length];
    NSMutableData *payloadData = [[NSMutableData alloc] initWithCapacity:_data.length];
    VCAnnexBFormatStreamParseState state = VCAnnexBFormatStreamParseStateInit;
    
    NSUInteger nextFramePos = _data.length;
    uint8_t *ptr = (uint8_t *)[_data bytes];
    
    for (NSUInteger i = 0; i < _data.length; ++i) {
        uint8_t byte = *(ptr + i);
        // alsosee: ffmpeg h264_find_frame_end()
        
        if (state == VCAnnexBFormatStreamParseStateInit) {
            if (byte == 0) {
                state = VCAnnexBFormatStreamParseStateFind1Zero;
            }
        } else if (state <= VCAnnexBFormatStreamParseStateFind1Zero) {
            // 找到0的时候
            if (byte == 1) {
                // 发现一个1
                state ^= VCAnnexBFormatStreamParseStateFindMoreThan2ZeroAnd1One;
            } else if (byte) {
                state = VCAnnexBFormatStreamParseStateInit;
            } else {
                state >>= 1; // 发现一个0
            }
        } else if (state <= VCAnnexBFormatStreamParseStateFindMoreThan2ZeroAnd1One) {
            if (state == VCAnnexBFormatStreamParseStateFind2ZeroAnd1One) {
                // 找到 00 00 01
                if (payloadData.length > 3) {
                    uint32_t len = CFSwapInt32HostToBig((uint32_t)payloadData.length - 3);
                    [outputData appendBytes:&len length:4];
                    [outputData appendData:[payloadData subdataWithRange:NSMakeRange(0, payloadData.length - 3)]];
                    payloadData = [[NSMutableData alloc] initWithCapacity:_data.length];
                }
            } else if (state == VCAnnexBFormatStreamParseStateFindMoreThan2ZeroAnd1One) {
                // 找到 00 00 00 01
                if (payloadData.length > 4) {
                    uint32_t len = CFSwapInt32HostToBig((uint32_t)payloadData.length - 4);
                    [outputData appendBytes:&len length:4];
                    [outputData appendData:[payloadData subdataWithRange:NSMakeRange(0, payloadData.length - 4)]];
                    payloadData = [[NSMutableData alloc] initWithCapacity:_data.length];
                }
            }
            nextFramePos = i;
            state = VCAnnexBFormatStreamParseStateInit;
        } else {
            // TODO
            
        }
        
        if (i >= nextFramePos) {
            // read data
            [payloadData appendBytes:&byte length:1];
        }
    }
    
    if (payloadData.length > 0) {
        // 末尾数据
        uint32_t len = CFSwapInt32HostToBig((uint32_t)payloadData.length);
        [outputData appendBytes:&len length:4];
        [outputData appendData:payloadData];
        payloadData = [[NSMutableData alloc] init];
    }
    
    VCAVCFormatStream *avcStream = [[VCAVCFormatStream alloc] initWithData:outputData startCodeLength:4];
    return avcStream;
}

@end
