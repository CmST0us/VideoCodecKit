//
//  VCVideoDecoder.h
//  VideoCodecKit
//
//  Created by CmST0us on 2019/1/19.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class VCSampleBuffer;
@protocol VCVideoDecoder <NSObject>
@required
- (OSStatus)decodeSampleBuffer:(VCSampleBuffer *)sampleBuffer;
@end

@protocol VCVideoDecoderDelegate <NSObject>
- (void)videoDecoder:(id<VCVideoDecoder>)decoder didOutputSampleBuffer:(VCSampleBuffer *)sampleBuffer;
@end

NS_ASSUME_NONNULL_END
