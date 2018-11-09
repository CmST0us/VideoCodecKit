//
//  VCBaseFrame.m
//  VideoCodecKit
//
//  Created by CmST0us on 2018/10/19.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import "VCBaseFrame.h"

CONST_STRING(kVCBaseFrameUserInfoFFmpegAVCodecContextKey);
CONST_STRING(kVCBaseFrameUserInfoAudioPropertyDictionaryKey);

@implementation VCBaseFrame {
    uint8_t *_parseDataPtr;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _userInfo = [NSMutableDictionary dictionary];
        _parseData = NULL;
        _parseDataPtr = NULL;
        _parseSize = 0;
    }
    return self;
}

- (void)createParseDataWithSize:(NSUInteger)size {
    self.parseSize = size;
    // 便于后面不同 startCode 转换
    // 便于编码时补充 start code
    _parseDataPtr = (uint8_t *)malloc(size + 4);
    self.parseData = _parseDataPtr + 4;
    memset(_parseDataPtr, 0, size + 4);
}

- (void)useExternParseDataLength:(NSUInteger)length {
    self.parseData -= length;
    self.parseSize += length;
}

- (void)dealloc {
    if (_parseDataPtr != NULL) {
        free(_parseDataPtr);
        self.parseData = NULL;
        _parseDataPtr = NULL;
        self.parseSize = 0;
    }
}
@end
