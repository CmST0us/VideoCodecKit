//
//  VCSampleBufferRender.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/21.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "VCSampleBufferRender.h"
#import "VCYUV420PImage.h"
#import "VCImageTypeProtocol.h"

@interface VCSampleBufferRender ()
@property (nonatomic, strong) AVSampleBufferDisplayLayer *renderLayer;
@end

@implementation VCSampleBufferRender

#pragma mark - Support Render Image Class Name
- (NSArray<NSString *> *)supportRenderImageClassName {
    return @[
             NSStringFromClass([VCYUV420PImage class]),
             ];
}

#pragma mark - Init Method
- (instancetype)init {
    self = [super init];
    if (self) {
        _renderLayer = nil;
    }
    return self;
}

- (AVSampleBufferDisplayLayer *)renderLayer {
    if (_renderLayer != nil) {
        return _renderLayer;
    }
    _renderLayer = [[AVSampleBufferDisplayLayer alloc] init];
    return _renderLayer;
}

- (instancetype)initWithSuperLayer:(CALayer *)layer {
    self = [self init];
    _superLayer = layer;
    return self;
}

- (void)attachToLayer:(CALayer *)layer {
    if (layer != nil && _superLayer != layer) {
        self.renderLayer.frame = layer.bounds;
        _superLayer = layer;
        [layer addSublayer:self.renderLayer];
    }
}

- (void)detachLayer {
    if ([self superLayer]) {
        [self.renderLayer removeFromSuperlayer];
    }
}
- (void)attachToSuperLayer {
    [self attachToLayer:_superLayer];
}

- (void)renderImage:(id<VCImageTypeProtocol>)image {
    if (image == nil) return;
    NSArray *supportImages = [self supportRenderImageClassName];
    BOOL isSupportRenderImage = NO;
    for (NSString *imageName in supportImages) {
        if ([image.classStringForImageType isEqualToString:imageName]) {
            isSupportRenderImage = YES;
        }
    }
    if (!isSupportRenderImage) {
        return;
    }
    
    CVPixelBufferRef pixelBuffer = image.pixelBuffer;
    if (pixelBuffer == NULL) {
        return;
    }
    
    CMSampleBufferRef sampleBuffer = [[self class] sampleBufferWithPixelBuffer:pixelBuffer];
    if (sampleBuffer != NULL && self.renderLayer.isReadyForMoreMediaData) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(sampleBufferRenderWillEnqueue:)]) {
            [self.delegate sampleBufferRenderWillEnqueue:sampleBuffer];
        }
        
        [self.renderLayer enqueueSampleBuffer:sampleBuffer];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(sampleBufferRenderDidEnqueue:)]) {
            [self.delegate sampleBufferRenderDidEnqueue:sampleBuffer];
        }
        CFRelease(sampleBuffer);
        sampleBuffer = NULL;
    }
    
    if (sampleBuffer != NULL) {
        CFRelease(sampleBuffer);
        sampleBuffer = NULL;
    }
}

+ (CMSampleBufferRef)sampleBufferWithPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    CMSampleTimingInfo timing = {kCMTimeInvalid, kCMTimeInvalid, kCMTimeInvalid};
    CMVideoFormatDescriptionRef videoInfo = NULL;
    CMSampleBufferRef sampleBuffer = NULL;
    OSStatus ret;
    
    ret = CMVideoFormatDescriptionCreateForImageBuffer(NULL, pixelBuffer, &videoInfo);
    if (ret != 0) {
        return NULL;
    }
    
    ret = CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer, true, NULL, NULL, videoInfo, &timing, &sampleBuffer);
    if (ret != 0) {
        return NULL;
    }

    CFArrayRef attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, YES);
    CFMutableDictionaryRef dict = (CFMutableDictionaryRef)CFArrayGetValueAtIndex(attachments, 0);
    CFDictionarySetValue(dict, kCMSampleAttachmentKey_DisplayImmediately, kCFBooleanTrue);
    CFRelease(videoInfo);
    return sampleBuffer;
}


@end
