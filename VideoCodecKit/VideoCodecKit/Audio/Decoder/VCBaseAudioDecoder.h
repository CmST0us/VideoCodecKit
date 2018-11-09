//
//  VCBaseAudioDecoder.h
//  VideoCodecKit
//
//  Created by CmST0us on 2018/11/6.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCBaseCodec.h"
#import "VCBaseAudio.h"
#import "VCBaseFrame.h"

@protocol VCBaseAudioDecoderProtocol <NSObject>
@optional
- (void)decodeFrame:(VCBaseFrame *)frame
         completion:(void (^)(VCBaseAudio *audio))block;

@required
- (void)decodeWithFrame:(VCBaseFrame *)frame;
@end

@class VCBaseAudioDecoder;
@protocol VCBaseAudioDecoderDelegate <NSObject>
- (void)decoder:(VCBaseAudioDecoder *)decoder didProcessAudio:(VCBaseAudio *)audio;
@end

@interface VCBaseAudioDecoder : VCBaseCodec<VCBaseAudioDecoderProtocol>
@property (nonatomic, weak) id<VCBaseAudioDecoderDelegate> delegate;
@end
