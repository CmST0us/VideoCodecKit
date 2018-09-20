//
//  VCSampleBufferRender.h
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/21.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "VCBaseRender.h"

@interface VCSampleBufferRender : VCBaseRender
@property (nonatomic, strong) AVSampleBufferDisplayLayer *renderLayer;

- (instancetype)initWithSuperLayer:(CALayer *)layer;
- (void)attachToSuperLayer;

- (void)displaySampleBuffer:(CMSampleBufferRef)sampleBuffer;

+ (CMSampleBufferRef)sampleBufferWithPixelBuffer:(CVPixelBufferRef)pixelBuffer;
@end
