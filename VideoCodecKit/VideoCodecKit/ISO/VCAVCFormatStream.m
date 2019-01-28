//
//  VCAVCFormatStream.m
//  VideoCodecKit
//
//  Created by CmST0us on 2019/1/19.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "VCAVCFormatStream.h"
#import "VCAnnexBFormatStream.h"
#import "VCByteArray.h"

@implementation VCAVCFormatStream
- (instancetype)initWithData:(NSData *)aData
             startCodeLength:(NSUInteger)startCodeLength {
    self = [super self];
    if (self) {
        _data = aData;
        _startCodeLength = startCodeLength;
    }
    return self;
}

- (VCAnnexBFormatStream *)toAnnexBFormatData {
    NSMutableData *outputData = [[NSMutableData alloc] init];
    static uint8_t startCode[4] = {0x00, 0x00, 0x00, 0x01};
    
    VCByteArray *array = [[VCByteArray alloc] initWithData:_data];
    
    @try {
        do {
            uint32_t len = [array readUInt32];
            [outputData appendBytes:startCode length:4];
            [outputData appendData:[array readBytes:len]];
        } while (array.bytesAvailable > 0);
        VCAnnexBFormatStream *data = [[VCAnnexBFormatStream alloc] initWithData:outputData];
        return data;
    } @catch (VCByteArrayException *exception) {
        return nil;
    }
}

@end
