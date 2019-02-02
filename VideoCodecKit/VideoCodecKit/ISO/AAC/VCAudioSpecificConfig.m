//
//  VCAudioSpecificConfig.m
//  VideoCodecKit
//
//  Created by CmST0us on 2019/1/31.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "VCAudioSpecificConfig.h"
#import "VCByteArray.h"

@interface VCAudioSpecificConfig ()
@property (nonatomic, strong) NSData *data;
@end

@implementation VCAudioSpecificConfig

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        _data = data;
        VCByteArray *array = [[VCByteArray alloc] initWithData:data];
        uint16_t v = [array readUInt16];
        
        _objectType = (AudioFormatFlags)((v >> 11) & 0x1F);
        _sampleRateIndex = (VCAudioSpecificConfigObjectTypeSampleRateIndex)((v >> 7) & 0x0F);
        _channels = ((v >> 3) & 0x0F);
        _frameLengthFlag = ((v >> 2) & 0x01);
        _isDependOnCoreCoder = ((v >> 1) & 0x01);
        _isExtension = ((v >> 0) & 0x01);
    }
    return self;
}

- (OSStatus)createAudioFormatDescription:(CMFormatDescriptionRef *)outputDescription {
    AudioStreamBasicDescription basicDescription;
    basicDescription.mFormatID = kAudioFormatMPEG4AAC;
    basicDescription.mSampleRate = self.sampleRate;
    basicDescription.mFormatFlags = self.objectType;
    basicDescription.mBytesPerFrame = 0;
    basicDescription.mFramesPerPacket = 1024;
    basicDescription.mBytesPerPacket = 0;
    basicDescription.mChannelsPerFrame = self.channels;
    basicDescription.mBitsPerChannel = 0;
    basicDescription.mReserved = 0;
    
    return CMAudioFormatDescriptionCreate(kCFAllocatorDefault, &basicDescription, 0, NULL, 0, NULL, NULL, outputDescription);
}

- (NSInteger)sampleRate {
    switch (self.sampleRateIndex) {
        case VCAudioSpecificConfigObjectTypeSampleRateIndex16000:
            return 16000;
        case VCAudioSpecificConfigObjectTypeSampleRateIndex22050:
            return 22050;
        case VCAudioSpecificConfigObjectTypeSampleRateIndex24000:
            return 24000;
        case VCAudioSpecificConfigObjectTypeSampleRateIndex32000:
            return 32000;
        case VCAudioSpecificConfigObjectTypeSampleRateIndex44100:
            return 44100;
        case VCAudioSpecificConfigObjectTypeSampleRateIndex64000:
            return 64000;
        case VCAudioSpecificConfigObjectTypeSampleRateIndex48000:
            return 48000;
        case VCAudioSpecificConfigObjectTypeSampleRateIndex88200:
            return 88200;
        case VCAudioSpecificConfigObjectTypeSampleRateIndex96000:
            return 96000;
    }
    return 44100;
}

- (AudioFormatFlags)formatFlags {
    // seealso: https://wiki.multimedia.cx/index.php?title=MPEG-4_Audio
    return (AudioFormatFlags)self.objectType;
}
@end
