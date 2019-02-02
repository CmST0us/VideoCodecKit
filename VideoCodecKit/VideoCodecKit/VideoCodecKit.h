//
//  VideoCodecKit.h
//  VideoCodecKit
//
//  Created by CmST0us on 2018/10/1.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for VideoCodecKit.
FOUNDATION_EXPORT double VideoCodecKitVersionNumber;

//! Project version string for VideoCodecKit.
FOUNDATION_EXPORT const unsigned char VideoCodecKitVersionString[];

#import <VideoCodecKit/VCH264Frame.h>
#import <VideoCodecKit/VCH264SPSFrame.h>
#import <VideoCodecKit/VCH264PPSFrame.h>
#import <VideoCodecKit/VCBaseImage.h>
#import <VideoCodecKit/VCH264Image.h>
#import <VideoCodecKit/VCYUV420PImage.h>
#import <VideoCodecKit/VCBaseFrame.h>
#import <VideoCodecKit/VCBaseRenderProtocol.h>
#import <VideoCodecKit/VCDecoderProgress.h>
#import <VideoCodecKit/VCMarco.h>
#import <VideoCodecKit/VCVideoFPS.h>
#import <VideoCodecKit/VCAutoResizeLayerView.h>
#import <VideoCodecKit/VCBaseAudio.h>
#import <VideoCodecKit/VCAudioFrame.h>

// Parser
#import <VideoCodecKit/VCBaseFrameParser.h>
#import <VideoCodecKit/VCH264FFmpegFrameParser.h>
// Decoder
#import <VideoCodecKit/VCBaseDecoder.h>
#import <VideoCodecKit/VCVTH264Decoder.h>
#import <VideoCodecKit/VCBaseDecoderConfig.h>
#import <VideoCodecKit/VCH264FFmpegDecoder.h>
// Encoder
#import <VideoCodecKit/VCBaseEncoder.h>
#import <VideoCodecKit/VCBaseEncoderConfig.h>
#import <VideoCodecKit/VCH264EncoderConfig.h>
#import <VideoCodecKit/VCVTH264Encoder.h>
// Render
#import <VideoCodecKit/VCSampleBufferRender.h>
#import <VideoCodecKit/VCMetalRender.h>
// Service
#import <VideoCodecKit/VCPreviewer.h>

// Audio
#import <VideoCodecKit/VCAudioFrameParser.h>
#import <VideoCodecKit/VCAudioRender.h>


#pragma mark - New Interface
#import <VideoCodecKit/VCByteArray.h>
#import <VideoCodecKit/VCAnnexBFormatStream.h>
#import <VideoCodecKit/VCAVCFormatStream.h>
#import <VideoCodecKit/VCAnnexBFormatParser.h>

#import <VideoCodecKit/VCAudioSpecificConfig.h>

#import <VideoCodecKit/VCFLVReader.h>
#import <VideoCodecKit/VCFLVWriter.h>
#import <VideoCodecKit/VCFLVTag.h>
#import <VideoCodecKit/VCFLVFile.h>

#import <VideoCodecKit/VCH264HardwareDecoder.h>
#import <VideoCodecKit/VCAACAudioConverter.h>
#import <VideoCodecKit/VCAudioPCMRender.h>

