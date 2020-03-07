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
- (void)converter:(VCAudioConverter *)converter didOutputSampleBuffer:(VCSampleBuffer *)sampleBuffer;
- (void)converter:(VCAudioConverter *)converter didOutputFormatDescriptor:(CMFormatDescriptionRef)formatDescription;
@end

@class VCAudioSpecificConfig;
@interface VCAudioConverter : NSObject
@property (nonatomic, weak) id<VCAudioConverterDelegate> delegate;

@property (nonatomic, strong) AVAudioFormat *outputFormat;
@property (nonatomic, strong) AVAudioFormat *sourceFormat;

@property (nonatomic) UInt32 bitrate;
@property (nonatomic) UInt32 audioConverterQuality;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithOutputFormat:(AVAudioFormat *)outputFormat
                        sourceFormat:(AVAudioFormat *)sourceFormat
                            delegate:(id<VCAudioConverterDelegate>)delegate
                       delegateQueue:(dispatch_queue_t)queue;

- (OSStatus)convertSampleBuffer:(VCSampleBuffer *)sampleBuffer;
- (OSStatus)convertAudioBufferList:(const AudioBufferList *)audioBufferList
             presentationTimeStamp:(CMTime)pts;
- (void)reset;

@end

NS_ASSUME_NONNULL_END
