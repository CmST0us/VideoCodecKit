//
//  VCBaseAudioDecoderConfig.h
//  VideoCodecKit
//
//  Created by CmST0us on 2018/11/7.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudioTypes.h>

typedef NS_ENUM(NSInteger, VCBaseAudioSampleRate) {
    VCBaseAudioSampleRate44100 = 44100, // Default
    VCBaseAudioSampleRate48000 = 48000,
};

@interface VCBaseAudioDecoderConfig : NSObject
@property (nonatomic, assign) VCBaseAudioSampleRate     sampleRate;
// Default is kAudioFormatLinearPCM
@property (nonatomic, assign) AudioFormatID              formatID;
// Default is kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsNonInterleaved
@property (nonatomic, assign) AudioFormatFlags           formatFlags;
@property (nonatomic, assign) NSUInteger                 bytesPerPacket;     // Default is 2
@property (nonatomic, assign) NSUInteger                 framesPerPacket;    // Default is 1
@property (nonatomic, assign) NSUInteger                 bytesPerFrame;      // Default is 2
@property (nonatomic, assign) NSUInteger                 channelsPerFrame;   // Default is 1
@property (nonatomic, assign) NSUInteger                 bitsPerChannel;     // Default is 16
@property (nonatomic, assign) NSUInteger                 reserved;           // Default is 0

- (AudioStreamBasicDescription)audioStreamBasicDescription;
@end
