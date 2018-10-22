//
//  VCPreviewer.h
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/21.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCH264Frame.h"
#import "VCH264Image.h"
#import "VCBaseDecoder.h"
#import "VCBaseFrameParser.h"
#import "VCBaseRenderProtocol.h"
#import "VCYUV420PImage.h"
#import "VCH264FFmpegDecoder.h"
#import "VCH264FFmpegFrameParser.h"
#import "VCSampleBufferRender.h"
#import "VCVTH264Decoder.h"

@class VCPreviewer;
@protocol VCPreviewerDelegate<NSObject>
- (void)previewer:(VCPreviewer *)aPreviewer didProcessImage:(VCBaseImage *)aImage;
@end

typedef NS_ENUM(NSUInteger, VCPreviewerType) {
    VCPreviewerTypeFFmpegLiveH264VideoOnly, // 使用ffmpeg和AVSampleBufferDisplayLayer
    VCPreviewerTypeVTLiveH264VideoOnly, // 使用VideoToolBox和AVSampleBufferDisplayLayer
};

@interface VCPreviewer : EKFSMObject<VCBaseFrameParserDelegate, VCBaseDecoderDelegate>

@property (nonatomic, strong) VCBaseFrameParser *parser;
@property (nonatomic, strong) VCBaseDecoder *decoder;
@property (nonatomic, strong) id<VCBaseRenderProtocol> render;

@property (nonatomic, assign) NSInteger watermark;

@property (nonatomic, assign) VCPreviewerType previewType;

@property (nonatomic, weak) id<VCPreviewerDelegate> delegate;

@property (nonatomic, assign) NSInteger fps;

- (instancetype)initWithType:(VCPreviewerType)previewType;

- (BOOL)feedData:(uint8_t *)data length:(int)length;
- (BOOL)canFeedData;
- (void)endFeedData;

- (void)run;
- (void)stop;
- (void)pause;

- (void)reset;

@end
