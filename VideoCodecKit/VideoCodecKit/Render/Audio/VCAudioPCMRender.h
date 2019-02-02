//
//  VCAudioPCMRender.h
//  VideoCodecKit
//
//  Created by CmST0us on 2019/2/2.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VCAudioPCMRender : NSObject
- (instancetype)initWithPCMFormat:(AVAudioFormat *)format;
- (void)renderPCMBuffer:(AVAudioPCMBuffer *)pcmBuffer withPresentationTimeStamp:(CMTime)presentationTimeStamp completionHandler:(AVAudioNodeCompletionHandler __nullable)handler;

- (void)play;
- (void)pause;
- (void)stop;
@end

NS_ASSUME_NONNULL_END
