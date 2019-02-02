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

@class VCAACAudioConverter;
@protocol VCAACAudioConverterDelegate <NSObject>
- (void)converter:(VCAACAudioConverter *)converter didGetPCMBuffer:(AVAudioPCMBuffer *)pcmBuffer presentationTimeStamp:(CMTime)pts;
@end

@interface VCAACAudioConverter : NSObject
@property (nonatomic, weak) id<VCAACAudioConverterDelegate> delegate;

// Not useful after convert;
- (void)setFormatDescription:(CMFormatDescriptionRef)desc;
- (AVAudioFormat *)outputFormat;
+ (AVAudioFormat *)outputFormatWithSampleRate:(Float64)sampleRate
                                     channels:(UInt32)channels;

- (OSStatus)convertSampleBuffer:(VCSampleBuffer *)sampleBuffer;
- (void)reset;

@end

NS_ASSUME_NONNULL_END
