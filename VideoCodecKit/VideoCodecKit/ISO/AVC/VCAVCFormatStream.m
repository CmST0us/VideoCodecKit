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
#import "VCH264NALU.h"

@interface VCAVCFormatStream ()
@property (nonatomic, copy) NSArray<VCH264NALU *> *nalus;
@end

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
            uint32_t len = 0;
            if (self.startCodeLength == 4) {
                len = [array readUInt32];
            } else if (self.startCodeLength == 3) {
                len = [array readUInt24];
            }
            [outputData appendBytes:startCode length:4];
            [outputData appendData:[array readBytes:len]];
        } while (array.bytesAvailable > 0);
        VCAnnexBFormatStream *data = [[VCAnnexBFormatStream alloc] initWithData:outputData];
        return data;
    } @catch (VCByteArrayException *exception) {
        return nil;
    }
}

- (NSArray *)nalus {
    if (_nalus) {
        return _nalus;
    }
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    VCByteArray *array = [[VCByteArray alloc] initWithData:_data];
    @try {
        do {
            uint32_t len = 0;
            if (self.startCodeLength == 4) {
                len = [array readUInt32];
            } else if (self.startCodeLength == 3) {
                len = [array readUInt24];
            }
            NSData *naluData = [array readBytes:len];
            id naluObj = [[self.naluClass alloc] initWithData:naluData];
            if (naluObj) {
                [arr addObject:naluObj];
            }
            
        } while (array.bytesAvailable > 0);
    } @catch (NSException *exception) {
        _nalus = arr;
        return _nalus;
    }
    _nalus = arr;
    return _nalus;
}
@end
