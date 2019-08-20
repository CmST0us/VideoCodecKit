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

@interface VCH264HardwareEncoder : NSObject<VCVideoEncoder>

@property (nonatomic, weak) id<VCVideoEncoderDelegate> delegate;
@property (nonatomic, strong) NSDictionary *imageBufferAttributes; //defaultAttributes
@property (nonatomic, strong) NSDictionary *properties; //defaultAttributes

// Encoder Configuration
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, assign) NSInteger bitrate;
@property (nonatomic, assign) double frameRate;
@property (nonatomic, copy) NSString *profileLevel; //kVTCompressionPropertyKey_ProfileLevel
@property (nonatomic, assign) NSInteger maxKeyFrameInterval;
@property (nonatomic, assign) double maxKeyFrameIntervalDuration;
@property (nonatomic, assign) BOOL realTime;

+ (NSDictionary *)defaultProperties;
+ (NSArray *)supportProperties;

+ (NSDictionary *)defaultImageBufferAttributes;

- (OSStatus)encodeSampleBuffer:(VCSampleBuffer *)sampleBuffer;

@end

NS_ASSUME_NONNULL_END
