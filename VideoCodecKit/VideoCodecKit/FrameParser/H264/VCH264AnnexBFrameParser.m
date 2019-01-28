//
//  VCH264AnnexBFrameParser.m
//  VideoCodecKit
//
//  Created by CmST0us on 2019/1/28.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "VCH264AnnexBFrameParser.h"
#import "VCAnnexBFormatParser.h"
#import "VCAnnexBFormatStream.h"

@interface VCH264AnnexBFrameParser ()
@property (nonatomic, strong) VCAnnexBFormatParser *parser;
@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, assign) NSInteger frameIndex;
@property (nonatomic, strong) NSMutableData *keyFrameData;
@end

@implementation VCH264AnnexBFrameParser

- (instancetype)init {
    self = [super init];
    if (self) {
        _parser = [[VCAnnexBFormatParser alloc] init];
        _lock = [[NSLock alloc] init];
        _frameIndex = 0;
        _keyFrameData = [[NSMutableData alloc] init];
    }
    return self;
}

- (NSInteger)parseData:(void *)buffer
                length:(NSInteger)length {
    [_lock lock];
    [_parser appendData:[NSData dataWithBytes:buffer length:length]];
    VCAnnexBFormatStream *next = nil;
    NSInteger useLen = 0;
    do {
        next = [_parser next];
        if (next == nil) break;
        useLen += next.data.length;
        VCH264Frame *frame = [[VCH264Frame alloc] init];
        [frame createParseDataWithSize:next.data.length];
        memcpy(frame.parseData, next.data.bytes, next.data.length);
        frame.frameIndex = 0;
        frame.frameType = [VCH264Frame getFrameType:frame];
        
        if (frame.frameType == VCH264FrameTypeSPS) {
            [_keyFrameData appendData:next.data];
        } else if (frame.frameType == VCH264FrameTypePPS) {
            [_keyFrameData appendData:next.data];
        } else if (frame.frameType == VCH264FrameTypeIDR) {
            [_keyFrameData appendData:next.data];
            VCH264Frame *keyFrame = [[VCH264Frame alloc] init];
            [keyFrame createParseDataWithSize:_keyFrameData.length];
            memcpy(keyFrame.parseData, _keyFrameData.bytes, _keyFrameData.length);
            keyFrame.frameType = [VCH264Frame getFrameType:keyFrame];
            keyFrame.frameIndex = 0;
            keyFrame.isKeyFrame = YES;
            if (self.delegate && [self.delegate respondsToSelector:@selector(frameParserDidParseFrame:)]) {
                [self.delegate frameParserDidParseFrame:keyFrame];
            }
            _keyFrameData = [[NSMutableData alloc] init];
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(frameParserDidParseFrame:)]) {
                [self.delegate frameParserDidParseFrame:frame];
            }
        }
        
    } while (next != nil);
    
    [_lock unlock];
    return useLen;
}
@end
