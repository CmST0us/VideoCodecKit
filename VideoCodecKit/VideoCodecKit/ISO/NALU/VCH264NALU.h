//
//  VCH264NALU.h
//  VideoCodecKit
//
//  Created by CmST0us on 2020/1/27.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, VCH264NALUType) {
    VCH264NALUTypeNoSpecific = 0,
    VCH264NALUTypeSliceData = 1, // 一个非IDR图像的编码条带
    VCH264NALUTypeSliceDataPartitionALayer = 2, // 编码条带数据分割块A
    VCH264NALUTypeSliceDataPartitionBLayer = 3, // 编码条带数据分割块B
    VCH264NALUTypeSliceDataPartitionCLayer = 4, // 编码条带数据分割块C
    VCH264NALUTypeSliceIDR = 5, // IDR图像的编码条带
    VCH264NALUTypeSEI = 6, // 辅助增强信息 SEI
    VCH264NALUTypeSeqParameterSet = 7, // 序列参数集 SPS
    VCH264NALUTypePicParameterSet = 8, // 图像参数集 PPS
    VCH264NALUTypeAccessUnitDelimiter = 9, // 访问单元分隔符 AUD
    VCH264NALUTypeEndOfSeq = 10, // 序列结尾 EOSEQ
    VCH264NALUTypeEndOfStream = 11, // 流结尾 EOSTREAM
    VCH264NALUTypeFillData = 12, // 填充数据 FILL
    VCH264NALUTypeSeqParameterSetExtension = 13, // 序列参数集扩展
    VCH264NALUTypeSliceLayerWithouPartitioning = 19, // 未分割的辅助编码图像的编码条带
};

@interface VCH264NALU : NSObject

@property (nonatomic, readonly) NSData *data;
@property (nonatomic, readonly) VCH264NALUType type;
- (instancetype)initWithData:(NSData *)data;

- (NSData *)warpAVCStartCode;
- (NSData *)warpAnnexBStartCode;

@end

NS_ASSUME_NONNULL_END
