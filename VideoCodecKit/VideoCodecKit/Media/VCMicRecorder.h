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
@property (nonatomic, readonly, nullable) AVAudioFormat *outputFormat;

- (instancetype)initWithOutputFormat:(AVAudioFormat * __nullable)format;
- (BOOL)startRecoderWithBlock:(AVAudioNodeTapBlock)block;
- (void)stop;
@end

NS_ASSUME_NONNULL_END
