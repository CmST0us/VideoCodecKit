//
//  VCAVCFormatStream.h
//  VideoCodecKit
//
//  Created by CmST0us on 2019/1/19.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
// conver avc format to annex-b format
// AVC Format:
// xx xx xx xx [4 bytes length] | xx xx xx xx .... [data]
// Annex-B Format:
// 00 00 00 01 xx xx xx xx
// 00 00 01 xx xx xx
// ------------------------------------------------------
@class VCAnnexBFormatStream;
@interface VCAVCFormatStream : NSObject

@property (nonatomic, readonly) NSData *data;
@property (nonatomic, readonly) NSUInteger startCodeLength;

- (instancetype)initWithData:(NSData *)aData
             startCodeLength:(NSUInteger)startCodeLength;

- (VCAnnexBFormatStream *)toAnnexBFormatData;

@end

NS_ASSUME_NONNULL_END
