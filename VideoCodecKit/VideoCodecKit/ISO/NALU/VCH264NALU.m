//
//  VCH264NALU.m
//  VideoCodecKit
//
//  Created by CmST0us on 2020/1/27.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import "VCByteArray.h"
#import "VCH264NALU.h"

@interface VCH264NALU ()
@property (nonatomic, strong) NSData *data;
@end

@implementation VCH264NALU

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        _data = data;
    }
    return self;
}

- (VCH264NALUType)type {
    VCByteArray *byteArray = [[VCByteArray alloc] initWithData:_data];
    uint8_t header = [byteArray readUInt8];
    uint8_t naluType = (header & 0x1F);
    return naluType;
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

- (NSString *)description
{
    return [NSString stringWithFormat:@"NALU Type: %@", [VCH264NALU NALUTypeDescription][@(self.type)]];
}

+ (NSDictionary<NSNumber *, NSString *> *)NALUTypeDescription {
    static NSDictionary *description = nil;
    if (description == nil) {
        description = @{
            @(VCH264NALUTypeNoSpecific): @"未指定",
            @(VCH264NALUTypeSliceData): @"一个非IDR图像的编码条带",
            @(VCH264NALUTypeSliceDataPartitionALayer): @"编码条带数据分割块A",
            @(VCH264NALUTypeSliceDataPartitionBLayer): @"编码条带数据分割块B",
            @(VCH264NALUTypeSliceDataPartitionCLayer): @"编码条带数据分割块C",
            @(VCH264NALUTypeSliceIDR): @"IDR图像的编码条带",
            @(VCH264NALUTypeSEI): @"辅助增强信息 SEI",
            @(VCH264NALUTypeSeqParameterSet): @"序列参数集 SPS",
            @(VCH264NALUTypePicParameterSet): @"图像参数集 PPS",
            @(VCH264NALUTypeAccessUnitDelimiter): @"访问单元分隔符 AUD",
            @(VCH264NALUTypeEndOfSeq): @"序列结尾 EOSEQ",
            @(VCH264NALUTypeEndOfStream): @"流结尾 EOSTREAM",
            @(VCH264NALUTypeFillData): @"填充数据 FILL",
            @(VCH264NALUTypeSeqParameterSetExtension): @"序列参数集扩展",
            @(VCH264NALUTypeSliceLayerWithouPartitioning): @"未分割的辅助编码图像的编码条带",
        };
    }
    return description;
}

@end
