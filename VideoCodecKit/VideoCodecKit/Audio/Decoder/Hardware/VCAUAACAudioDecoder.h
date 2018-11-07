//
//  VCAUAACAudioDecoder.h
//  VideoCodecKit
//
//  Created by CmST0us on 2018/11/6.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import "VCBaseAudioDecoder.h"
#import "VCAUAACAudioDecoderConfig.h"
@interface VCAUAACAudioDecoder : VCBaseAudioDecoder
@property (nonatomic, readonly) VCAUAACAudioDecoderConfig *config;
- (instancetype)initWithConfig:(VCAUAACAudioDecoderConfig *)config;
@end
