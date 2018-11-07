//
//  VCBaseAudioDecoderConfig.m
//  VideoCodecKit
//
//  Created by CmST0us on 2018/11/7.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import "VCBaseAudioDecoderConfig.h"

@implementation VCBaseAudioDecoderConfig
- (instancetype)init {
    self = [super init];
    if (self) {
        _sampleRate = VCBaseAudioSampleRate44100;
        _formatID = kAudioFormatLinearPCM;
        _formatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsNonInterleaved;
        _framesPerPacket = 1;
        _channelsPerFrame = 1;
        _bytesPerPacket = 2;
        _bytesPerFrame = 2;
        _bitsPerChannel = 16;
        _reserved = 0;
    }
    return self;
}

- (AudioStreamBasicDescription)audioStreamBasicDescription {
    AudioStreamBasicDescription desc;
    desc.mSampleRate = _sampleRate;
    desc.mFormatID = _formatID;
    desc.mFormatFlags = _formatFlags;
    desc.mFramesPerPacket = (UInt32)_framesPerPacket;
    desc.mChannelsPerFrame = (UInt32)_channelsPerFrame;
    desc.mBytesPerFrame = (UInt32)_bytesPerFrame;
    desc.mBytesPerPacket = (UInt32)_bytesPerPacket;
    desc.mBitsPerChannel = (UInt32)_bitsPerChannel;
    desc.mReserved = (UInt32)_reserved;
    return desc;
}

- (NSString *)description {
    char formatID[5];
    AudioStreamBasicDescription asbd = [self audioStreamBasicDescription];
    UInt32 mFormatID = CFSwapInt32HostToBig(asbd.mFormatID);
    bcopy (&mFormatID, formatID, 4);
    formatID[4] = '\0';
    NSString *descriptionStringFormat = @"\n"\
    "Sample Rate:         %10.0f\n"\
    "Format ID:           %10s\n"\
    "Format Flags:        %10X\n"\
    "Bytes per Packet:    %10d\n"\
    "Frames per Packet:   %10d\n"\
    "Bytes per Frame:     %10d\n"\
    "Channels per Frame:  %10d\n"\
    "Bits per Channel:    %10d\n";
    NSString *descriptionString = [[NSString alloc] initWithFormat:descriptionStringFormat,
                                   asbd.mSampleRate,
                                   formatID,
                                   (unsigned int)asbd.mFormatFlags,
                                   (unsigned int)asbd.mBytesPerPacket,
                                   (unsigned int)asbd.mFramesPerPacket,
                                   (unsigned int)asbd.mBytesPerFrame,
                                   (unsigned int)asbd.mChannelsPerFrame,
                                   (unsigned int)asbd.mBitsPerChannel
                                   ];
    return descriptionString;
}
@end
