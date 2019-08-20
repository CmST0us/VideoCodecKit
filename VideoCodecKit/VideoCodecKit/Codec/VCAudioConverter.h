//
//  VCAudioConverter.h
//  VideoCodecKit
//
//  Created by CmST0us on 2019/2/6.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "VCSampleBuffer.h"

NS_ASSUME_NONNULL_BEGIN

@class VCAudioConverter;
@protocol VCAudioConverterDelegate <NSObject>
- (void)converter:(VCAudioConverter *)converter didOutputAudioBuffer:(AVAudioBuffer *)audioBuffer presentationTimeStamp:(CMTime)pts;
@end

@interface VCAudioConverter : NSObject
@property (nonatomic, weak) id<VCAudioConverterDelegate> delegate;

@property (nonatomic, strong) AVAudioFormat *outputFormat;
@property (nonatomic, strong) AVAudioFormat *sourceFormat;

- (instancetype)initWithOutputFormat:(AVAudioFormat *)outputFormat
                        sourceFormat:(AVAudioFormat *)sourceFormat;

- (OSStatus)convertSampleBuffer:(VCSampleBuffer *)sampleBuffer;
- (OSStatus)convertAudioBufferList:(AudioBufferList *)audioBufferList
             presentationTimeStamp:(CMTime)pts;
- (void)reset;

+ (AVAudioFormat *)formatWithCMAudioFormatDescription:(CMAudioFormatDescriptionRef)audioFormatDescription;
+ (AVAudioFormat *)AACFormatWithSampleRate:(Float64)sampleRate
                               formatFlags:(AudioFormatFlags)flags
                                  channels:(UInt32)channels;
+ (AVAudioFormat *)PCMFormatWithSampleRate:(Float64)sampleRate
                                  channels:(UInt32)channels;
@end

NS_ASSUME_NONNULL_END
