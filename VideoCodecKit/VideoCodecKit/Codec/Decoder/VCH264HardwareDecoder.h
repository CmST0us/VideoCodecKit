//
//  VCH264HardwareDecoder.h
//  VideoCodecKit
//
//  Created by CmST0us on 2019/1/19.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCSampleBuffer.h"
#import "VCVideoDecoder.h"

NS_ASSUME_NONNULL_BEGIN

@interface VCH264HardwareDecoder : NSObject<VCVideoDecoder>

@property (nonatomic, weak) id<VCVideoDecoderDelegate> delegate;
@property (nonatomic, strong) NSDictionary *attributes; // defaultAttributes

+ (NSDictionary *)defaultAttributes;
- (void)setFormatDescription:(CMFormatDescriptionRef)formatDescription;

- (OSStatus)decodeSampleBuffer:(VCSampleBuffer *)sampleBuffer;
- (void)clear;

@end

NS_ASSUME_NONNULL_END
