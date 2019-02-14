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

#pragma mark - Utils
#import <VideoCodecKit/VCByteArray.h>
#import <VideoCodecKit/VCSafeObjectQueue.h>
#import <VideoCodecKit/VCSafeBuffer.h>

#pragma mark - Format
#pragma mark AnnexB
#import <VideoCodecKit/VCAnnexBFormatStream.h>
#import <VideoCodecKit/VCAnnexBFormatParser.h>
#pragma mark AVC
#import <VideoCodecKit/VCAVCFormatStream.h>
#import <VideoCodecKit/VCAVCConfigurationRecord.h>
#pragma mark AAC
#import <VideoCodecKit/VCAudioSpecificConfig.h>
#pragma mark FLV
#import <VideoCodecKit/VCFLVReader.h>
#import <VideoCodecKit/VCFLVWriter.h>
#import <VideoCodecKit/VCFLVTag.h>
#import <VideoCodecKit/VCFLVFile.h>
#pragma mark AMF
#import <VideoCodecKit/VCAMF0Serialization.h>
#import <VideoCodecKit/VCAMF3Serialization.h>
#import <VideoCodecKit/VCActionScriptTypes.h>

#pragma mark - Network
#pragma mark TCP Socket
#import <VideoCodecKit/VCTCPSocket.h>

#pragma mark RTMP
#import <VideoCodecKit/VCRTMPChunk.h>
#import <VideoCodecKit/VCRTMPMessage.h>
#import <VideoCodecKit/VCRTMPHandshake.h>
#import <VideoCodecKit/VCRTMPMuxer.h>
#import <VideoCodecKit/VCRTMPSocket.h>

#pragma mark - Codec
#import <VideoCodecKit/VCVideoDecoder.h>
#import <VideoCodecKit/VCVideoEncoder.h>
#import <VideoCodecKit/VCH264HardwareEncoder.h>
#import <VideoCodecKit/VCH264HardwareDecoder.h>
#import <VideoCodecKit/VCAudioConverter.h>

#pragma mark - Render
#import <VideoCodecKit/VCAudioPCMRender.h>

#pragma mark - Media
#import <VideoCodecKit/VCMicRecorder.h>

