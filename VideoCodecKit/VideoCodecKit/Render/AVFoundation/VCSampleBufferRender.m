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
#import "VCBaseImage.h"
#import "VCAutoResizeLayerView.h"

@interface VCSampleBufferRender ()
@property (nonatomic, strong) AVSampleBufferDisplayLayer *renderLayer;
@property (nonatomic, strong) VCAutoResizeLayerView *autoResizeLayerView;
@end

@implementation VCSampleBufferRender

#pragma mark - Support Render Image Class Name
- (NSArray<NSString *> *)supportRenderClassName {
    return @[
             NSStringFromClass([VCYUV420PImage class]),
             ];
}

#pragma mark - Init Method
- (instancetype)init {
    self = [super init];
    if (self) {
        _renderLayer = [[AVSampleBufferDisplayLayer alloc] init];;
        _autoResizeLayerView = [[VCAutoResizeLayerView alloc] init];
        [_autoResizeLayerView addAutoResizeSubLayer:_renderLayer];
    }
    return self;
}

- (UIView *)renderView {
    return _autoResizeLayerView;
}

- (void)attachToView:(UIView *)view {
    [_autoResizeLayerView removeFromSuperview];
    if (view && _autoResizeLayerView) {
        [view addSubview:_autoResizeLayerView];
    }
}

- (void)render:(id)image {
    if (image == nil) return;
    NSArray *supportImages = [self supportRenderClassName];
    BOOL isSupportRenderImage = NO;
    for (NSString *imageName in supportImages) {
        if ([NSStringFromClass([image class]) isEqualToString:imageName]) {
            isSupportRenderImage = YES;
        }
    }
    if (!isSupportRenderImage) {
        return;
    }
    
    CVPixelBufferRef pixelBuffer = ((VCYUV420PImage *)image).pixelBuffer;
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
