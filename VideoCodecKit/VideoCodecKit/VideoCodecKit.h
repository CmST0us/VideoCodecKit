//
//  VideoCodecKit.h
//  VideoCodecKit
//
//  Created by CmST0us on 2018/10/1.
//  Copyright © 2018年 eric3u. All rights reserved.
//
#if TARGET_OS_IOS
#import <UIKit/UIKit.h>

//! Project version number for VideoCodecKit.
FOUNDATION_EXPORT double VideoCodecKitVersionNumber;

//! Project version string for VideoCodecKit.
FOUNDATION_EXPORT const unsigned char VideoCodecKitVersionString[];
#endif

#import <VideoCodecKit/VCByteArray.h>
#import <VideoCodecKit/VCSafeObjectQueue.h>

#import <VideoCodecKit/VCAnnexBFormatStream.h>
#import <VideoCodecKit/VCAnnexBFormatParser.h>
#import <VideoCodecKit/VCAVCFormatStream.h>
#import <VideoCodecKit/VCAVCConfigurationRecord.h>
#import <VideoCodecKit/VCAudioSpecificConfig.h>
#import <VideoCodecKit/VCH264NALU.h>

#import <VideoCodecKit/VCAssetReader.h>

#import <VideoCodecKit/VCFLVReader.h>
#import <VideoCodecKit/VCFLVWriter.h>
#import <VideoCodecKit/VCFLVTag.h>
#import <VideoCodecKit/VCFLVFile.h>

#import <VideoCodecKit/VCRawH264Reader.h>
#import <VideoCodecKit/VCRawH265Reader.h>

#import <VideoCodecKit/VCVideoDecoder.h>
#import <VideoCodecKit/VCVideoEncoder.h>
#import <VideoCodecKit/VCH264HardwareEncoder.h>
#import <VideoCodecKit/VCH264HardwareDecoder.h>
#import <VideoCodecKit/VCAudioConverter.h>

#import <VideoCodecKit/VCAudioPCMRender.h>

#import <VideoCodecKit/VCMicRecorder.h>
