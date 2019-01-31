//
//  VCSampleBuffer.h
//  VideoCodecKit
//
//  Created by CmST0us on 2019/1/19.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

NS_ASSUME_NONNULL_BEGIN

@interface VCSampleBuffer : NSObject
@property (nonatomic, assign) CMSampleBufferRef sampleBuffer;

@property (nonatomic) CMBlockBufferRef dataBuffer;
@property (nonatomic, readonly) CVImageBufferRef imageBuffer;
@property (nonatomic, readonly) CMItemCount numberOfSamples;
@property (nonatomic, readonly) CMTime duration;
@property (nonatomic, readonly) CMFormatDescriptionRef formatDescription;
@property (nonatomic, readonly) CMTime decodeTimeStamp;
@property (nonatomic, readonly) CMTime presentationTimeStamp;
@property (nonatomic, readonly) AudioStreamBasicDescription audioStreamBasicDescription;

- (instancetype)initWithSampleBuffer:(CMSampleBufferRef)aSampleBuffer NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
