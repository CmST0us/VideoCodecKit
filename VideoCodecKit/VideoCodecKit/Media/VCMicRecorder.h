//
//  VCMicRecorder.h
//  VideoCodecKit
//
//  Created by CmST0us on 2019/2/7.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VCMicRecorder : NSObject

@property (nonatomic, readonly) BOOL recording;

@property (nonatomic, assign) uint32_t sampleRate;
@property (nonatomic, assign) uint32_t channelCount;

@property (nonatomic, readonly) AVAudioFormat *outputFormat;

@property (nonatomic, readonly) AVAudioFormat *nodeFormat;

- (BOOL)startRecoderWithFormat:(AVAudioFormat *)format
                         block:(AVAudioNodeTapBlock)block;
- (void)stop;
@end

NS_ASSUME_NONNULL_END
