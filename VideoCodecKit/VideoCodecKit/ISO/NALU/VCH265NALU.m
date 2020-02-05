//
//  VCH265NALU.m
//  VideoCodecKit
//
//  Created by CmST0us on 2020/1/28.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import "VCH265NALU.h"
#import "VCByteArray.h"

@interface VCH265NALU ()
@property (nonatomic, strong) NSData *data;
@end

@implementation VCH265NALU

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        _data = data;
    }
    return self;
}

- (VCH265NALUType)type {
    VCByteArray *byteArray = [[VCByteArray alloc] initWithData:_data];
    uint8_t header = [byteArray readUInt8];
    uint8_t type = (header & 0x7E) >> 1;
    return type;
}

- (NSData *)warpAVCStartCode {
    uint32_t len = CFSwapInt32HostToBig((uint32_t)self.data.length);
    NSMutableData *data = [[NSMutableData alloc] initWithCapacity:4 + self.data.length];
    [data appendBytes:&len length:4];
    [data appendData:self.data];
    return data;
}

- (NSData *)warpAnnexBStartCode {
    static uint8_t startCode[4] = {0, 0, 0, 1};
    NSMutableData *data = [[NSMutableData alloc] initWithCapacity:4 + self.data.length];
    [data appendBytes:&startCode length:4];
    [data appendData:self.data];
    return data;
}

- (NSString *)description {
    NSString *s = [VCH265NALU NALUTypeDescription][@(self.type)];
    if (s == nil) {
        s = [NSString stringWithFormat:@"%@", @(self.type)];
    }
    return [NSString stringWithFormat:@"NALU Type: %@", s];
}

+ (NSDictionary<NSNumber *, NSString *> *)NALUTypeDescription {
    static NSDictionary *description = nil;
    if (description == nil) {
        description = @{
            @(VCH265NALUTypeVPS): @"VPS",
            @(VCH265NALUTypeSPS): @"SPS",
            @(VCH265NALUTypePPS): @"PPS",
            @(VCH265NALUTypeSEI): @"SEI",
            @(VCH265NALUTypeIDR): @"IDR",
            @(VCH265NALUTypeSliceN): @"SliceN",
            @(VCH265NALUTypeSliceR): @"SliceR",
            @(VCH265NALUTypeCRA): @"CRA"
        };
    }
    return description;
}

@end
