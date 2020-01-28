//
//  VCH265NALU.h
//  VideoCodecKit
//
//  Created by CmST0us on 2020/1/28.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, VCH265NALUType) {
    VCH265NALUTypeVPS = 32,
    VCH265NALUTypeSPS = 33,
    VCH265NALUTypePPS = 34,
    
};

@interface VCH265NALU : NSObject

@property (nonatomic, readonly) NSData *data;
@property (nonatomic, readonly) VCH265NALUType type;
- (instancetype)initWithData:(NSData *)data;

- (NSData *)warpAVCStartCode;
- (NSData *)warpAnnexBStartCode;

@end

NS_ASSUME_NONNULL_END
