//
//  VCSampleBufferRender.h
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/21.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "VCBaseRenderProtocol.h"

@protocol VCSampleBufferRenderDelegate<NSObject>
- (void)sampleBufferRenderWillEnqueue:(CMSampleBufferRef)sampleBuffer;
- (void)sampleBufferRenderDidEnqueue:(CMSampleBufferRef)sampleBuffer;
@end

@interface VCSampleBufferRender : NSObject<VCBaseRenderProtocol>
@property (nonatomic, readonly) AVSampleBufferDisplayLayer *renderLayer;
@property (nonatomic, weak) id<VCSampleBufferRenderDelegate> delegate;

- (instancetype)initWithSuperView:(UIView *)view;
- (void)attachToSuperView;

+ (CMSampleBufferRef)sampleBufferWithPixelBuffer:(CVPixelBufferRef)pixelBuffer;
@end
