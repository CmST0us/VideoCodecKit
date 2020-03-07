//
//  VCH264HardwareEncoder.h
//  VideoCodecKit
//
//  Created by CmST0us on 2019/1/19.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCVideoEncoder.h"
NS_ASSUME_NONNULL_BEGIN

@interface VCH264HardwareEncoderParameter : NSObject<NSCopying>
@property (nonatomic, copy) NSNumber *width;
@property (nonatomic, copy) NSNumber *height;
@property (nonatomic, copy) NSNumber *bitrate;
@property (nonatomic, copy) NSNumber *frameRate;
@property (nonatomic, copy) NSString *profileLevel;
@property (nonatomic, copy) NSNumber *maxKeyFrameInterval;
@property (nonatomic, copy) NSNumber *maxKeyFrameIntervalDuration;
@property (nonatomic, copy) NSNumber *allowFrameReordering;
@property (nonatomic, copy) NSNumber *realTime;
@end

@interface VCH264HardwareEncoder : NSObject<VCVideoEncoder>

@property (nonatomic, weak) id<VCVideoEncoderDelegate> delegate;
@property (nonatomic, strong) NSDictionary *imageBufferAttributes; //defaultAttributes
// Encoder Configuration
@property (nonatomic, readonly) VCH264HardwareEncoderParameter *parameter;

- (VCH264HardwareEncoderParameter *)beginConfiguration;
- (void)commitConfiguration;

- (OSStatus)encodeSampleBuffer:(VCSampleBuffer *)sampleBuffer;

+ (NSArray *)supportProperties;
+ (NSDictionary *)defaultImageBufferAttributes;
@end

NS_ASSUME_NONNULL_END
