//
//  VCAnnexBFormatStream.h
//  VideoCodecKit
//
//  Created by CmST0us on 2019/1/19.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
// Convert annex-b format to avc format
// Annex-B Format:
// 00 00 00 01 xx xx xx ....
// 00 00 01 xx xx xx xx ....
// AVC Format:
// xx xx xx xx [4 bytes length] | xx xx xx xx .... [data]
// -----------------------------
@class VCAVCFormatStream;
@interface VCAnnexBFormatStream : NSObject

@property (nonatomic, readonly) NSData *data;
// 使用AnnexB格式数据初始化
- (instancetype)initWithData:(NSData *)aData;

- (VCAVCFormatStream *)toAVCFormatStream;

@end

NS_ASSUME_NONNULL_END
