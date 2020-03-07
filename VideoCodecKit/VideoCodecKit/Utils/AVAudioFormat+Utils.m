//
//  AVAudioFormat+Utils.m
//  VideoCodecKit
//
//  Created by CmST0us on 2020/3/7.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import "AVAudioFormat+Utils.h"

@implementation AVAudioFormat (Utils)

+ (AVAudioFormat *)AACFormatWithSampleRate:(Float64)sampleRate channels:(UInt32)channels {
    return [AVAudioFormat AACFormatWithSampleRate:sampleRate
                                      formatFlags:kMPEG4Object_AAC_LC
                                         channels:channels];
}

+ (AVAudioFormat *)AACFormatWithSampleRate:(Float64)sampleRate
                               formatFlags:(AudioFormatFlags)flags
                                  channels:(UInt32)channels {
    AudioStreamBasicDescription basicDescription;
    basicDescription.mFormatID = kAudioFormatMPEG4AAC;
    basicDescription.mSampleRate = sampleRate;
    basicDescription.mFormatFlags = flags;
    basicDescription.mBytesPerFrame = 0;
    basicDescription.mFramesPerPacket = 1024;
    basicDescription.mBytesPerPacket = 0;
    basicDescription.mChannelsPerFrame = channels;
    basicDescription.mBitsPerChannel = 0;
    basicDescription.mReserved = 0;
    
    CMAudioFormatDescriptionRef outputDescription = nil;
    OSStatus ret = CMAudioFormatDescriptionCreate(kCFAllocatorDefault, &basicDescription, 0, NULL, 0, NULL, NULL, &outputDescription);
    if (ret != noErr) {
        return nil;
    }
    
    AVAudioFormat *format = [[AVAudioFormat alloc] initWithCMAudioFormatDescription:outputDescription];
    CFRelease(outputDescription);
    
    return format;
}

+ (AVAudioFormat *)formatWithCMAudioFormatDescription:(CMAudioFormatDescriptionRef)audioFormatDescription {
    AVAudioFormat *format = [[AVAudioFormat alloc] initWithCMAudioFormatDescription:audioFormatDescription];
    return format;
}

+ (AVAudioFormat *)PCMFormatWithSampleRate:(Float64)sampleRate
                                  channels:(UInt32)channels {
    AudioChannelLayoutTag channelLayoutTag = kAudioChannelLayoutTag_Stereo;
    if (channels == 1) {
        channelLayoutTag = kAudioChannelLayoutTag_Mono;
    } else if (channels == 2) {
        channelLayoutTag = kAudioChannelLayoutTag_Stereo;
    } else if (channels == 3) {
        channelLayoutTag = kAudioChannelLayoutTag_AAC_3_0;
    } else if (channels == 4) {
        channelLayoutTag = kAudioChannelLayoutTag_AAC_4_0;
    } else if (channels == 5) {
        channelLayoutTag = kAudioChannelLayoutTag_AAC_5_0;
    } else if (channels == 6) {
        channelLayoutTag = kAudioChannelLayoutTag_AAC_5_1;
    }
    AVAudioChannelLayout *layout = [[AVAudioChannelLayout alloc] initWithLayoutTag:channelLayoutTag];
    AVAudioFormat *format = [[AVAudioFormat alloc] initWithCommonFormat:AVAudioPCMFormatFloat32 sampleRate:sampleRate interleaved:NO channelLayout:layout];
    return format;
}

+ (AVAudioFormat *)defaultPCMFormat {
    return [AVAudioFormat PCMFormatWithSampleRate:44100 channels:2];
}

+ (AVAudioFormat *)defaultAACFormat {
    return [AVAudioFormat AACFormatWithSampleRate:44100 channels:2];
}
@end
