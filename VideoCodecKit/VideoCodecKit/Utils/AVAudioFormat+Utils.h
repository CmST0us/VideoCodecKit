//
//  AVAudioFormat+Utils.h
//  VideoCodecKit
//
//  Created by CmST0us on 2020/3/7.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVAudioFormat (Utils)

+ (AVAudioFormat *)AACFormatWithSampleRate:(Float64)sampleRate channels:(UInt32)channels;
+ (AVAudioFormat *)AACFormatWithSampleRate:(Float64)sampleRate
                               formatFlags:(AudioFormatFlags)flags
                                  channels:(UInt32)channels;
+ (AVAudioFormat *)PCMFormatWithSampleRate:(Float64)sampleRate
                                  channels:(UInt32)channels;

@end

NS_ASSUME_NONNULL_END
