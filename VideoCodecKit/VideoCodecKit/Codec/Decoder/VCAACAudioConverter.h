//
//  VCAACAudioConverter.h
//  VideoCodecKit
//
//  Created by CmST0us on 2019/1/31.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCSampleBuffer.h"

NS_ASSUME_NONNULL_BEGIN

@interface VCAACAudioConverter : NSObject


- (void)setFormatDescription:(CMFormatDescriptionRef)desc;
+ (AVAudioFormat *)outputFormatWithSampleRate:(Float64)sampleRate;

- (void)convertSampleBuffer:(VCSampleBuffer *)sampleBuffer;
- (void)reset;

@end

NS_ASSUME_NONNULL_END
