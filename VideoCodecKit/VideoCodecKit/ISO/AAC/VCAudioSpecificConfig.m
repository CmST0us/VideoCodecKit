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
@property (nonatomic, assign) VCAudioSpecificConfigObjectTypeSampleRateIndex sampleRateIndex;
@end

@implementation VCAudioSpecificConfig

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        _data = data;
    }
    return self;
}

- (OSStatus)createAudioFormatDescription:(CMFormatDescriptionRef *)outputDescription {
    if (outputDescription == NULL) {
        return -1;
    }
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

- (void)setSampleRate:(NSInteger)sampleRate {
    switch (sampleRate) {
        case 16000:
            self.sampleRateIndex = VCAudioSpecificConfigObjectTypeSampleRateIndex16000;
            break;
        case 22050:
            self.sampleRateIndex = VCAudioSpecificConfigObjectTypeSampleRateIndex22050;
            break;
        case 24000:
            self.sampleRateIndex = VCAudioSpecificConfigObjectTypeSampleRateIndex24000;
            break;
        case 32000:
            self.sampleRateIndex = VCAudioSpecificConfigObjectTypeSampleRateIndex32000;
            break;
        case 44100:
            self.sampleRateIndex = VCAudioSpecificConfigObjectTypeSampleRateIndex44100;
            break;
        case 64000:
            self.sampleRateIndex = VCAudioSpecificConfigObjectTypeSampleRateIndex64000;
            break;
        case 48000:
            self.sampleRateIndex = VCAudioSpecificConfigObjectTypeSampleRateIndex48000;
            break;
        case 88200:
            self.sampleRateIndex = VCAudioSpecificConfigObjectTypeSampleRateIndex88200;
            break;
        case 96000:
            self.sampleRateIndex = VCAudioSpecificConfigObjectTypeSampleRateIndex96000;
            break;
        default:
            self.sampleRateIndex = 44100;
            break;
    }
}

- (AudioFormatFlags)formatFlags {
    // seealso: https://wiki.multimedia.cx/index.php?title=MPEG-4_Audio
    return (AudioFormatFlags)self.objectType;
}

- (NSData *)serialize {
    VCByteArray *array = [[VCByteArray alloc] init];
    uint16_t v = 0;
    v |= (self.objectType & 0x1F) << 11; // 5 bit
    v |= (self.sampleRateIndex & 0x0F) << 7; // 4 bit
    v |= (self.channels & 0x0F) << 3; // 4 bit
    v |= (self.frameLengthFlag & 0x01) << 2; // 1bit
    v |= (self.isDependOnCoreCoder & 0x01) << 1; // 1bit
    v |= self.isExtension & 0x01; // 1 bit
    [array writeUInt16:v];
    return array.data;
}

- (void)deserialize {
    VCByteArray *array = [[VCByteArray alloc] initWithData:self.data];
    uint16_t v = [array readUInt16];
    
    self.objectType = (AudioFormatFlags)((v >> 11) & 0x1F);
    self.sampleRateIndex = (VCAudioSpecificConfigObjectTypeSampleRateIndex)((v >> 7) & 0x0F);
    self.channels = ((v >> 3) & 0x0F);
    self.frameLengthFlag = ((v >> 2) & 0x01);
    self.isDependOnCoreCoder = ((v >> 1) & 0x01);
    self.isExtension = ((v >> 0) & 0x01);
}

+ (NSData *)adtsDataForPacketLength:(NSUInteger)packetLength {
    int adtsLength = 7;
    uint8_t *packet = (uint8_t *)malloc(sizeof(uint8_t) * adtsLength);
    // Variables Recycled by addADTStoPacket
    int profile = 2;  //AAC LC
    //39=MediaCodecInfo.CodecProfileLevel.AACObjectELD;
    int freqIdx = 8;  //16KHz
    int chanCfg = 1;  //MPEG-4 Audio Channel Configuration. 1 Channel front-center
    NSUInteger fullLength = adtsLength + packetLength;
    // fill in ADTS data
    packet[0] = 0xFF; // 11111111     = syncword
    packet[1] = 0xF9; // 1111 1 00 1  = syncword MPEG-2 Layer CRC
    packet[2] = ((profile - 1) << 6) + (freqIdx << 2) + (chanCfg >> 2);
    packet[3] = ((chanCfg & 3) << 6) + (fullLength >> 11);
    packet[4] = (fullLength & 0x7FF) >> 3;
    packet[5] = ((fullLength & 7) << 5) + 0x1F;
    packet[6] = 0xFC;
    NSData *data = [NSData dataWithBytesNoCopy:packet length:adtsLength freeWhenDone:YES];
    return data;
}

@end
