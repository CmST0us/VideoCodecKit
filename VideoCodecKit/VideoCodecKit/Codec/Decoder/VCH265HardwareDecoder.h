//
//  VCH265HardwareDecoder.h
//  VideoCodecKit
//
//  Created by CmST0us on 2020/1/23.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCSampleBuffer.h"
#import "VCVideoDecoder.h"
NS_ASSUME_NONNULL_BEGIN

@interface VCH265HardwareDecoder : NSObject<VCVideoDecoder>

@property (nonatomic, weak) id<VCVideoDecoderDelegate> delegate;
@property (nonatomic, strong) NSDictionary *attributes;

+ (NSDictionary *)defaultAttributes;

- (OSStatus)decodeSampleBuffer:(VCSampleBuffer *)sampleBuffer;
- (void)cleat;

@end

NS_ASSUME_NONNULL_END
