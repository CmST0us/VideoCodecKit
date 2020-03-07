//
//  VCAudioSpecificConfig.h
//  VideoCodecKit
//
//  Created by CmST0us on 2019/1/31.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN

// seealso: https://wiki.multimedia.cx/index.php?title=MPEG-4_Audio
typedef NS_ENUM(uint8_t, VCAudioSpecificConfigObjectTypeSampleRateIndex) {
    VCAudioSpecificConfigObjectTypeSampleRateIndex96000 = 0,
    VCAudioSpecificConfigObjectTypeSampleRateIndex88200 = 1,
    VCAudioSpecificConfigObjectTypeSampleRateIndex64000 = 2,
    VCAudioSpecificConfigObjectTypeSampleRateIndex48000 = 3,
    VCAudioSpecificConfigObjectTypeSampleRateIndex44100 = 4,
    VCAudioSpecificConfigObjectTypeSampleRateIndex32000 = 5,
    VCAudioSpecificConfigObjectTypeSampleRateIndex24000 = 6,
    VCAudioSpecificConfigObjectTypeSampleRateIndex22050 = 7,
    VCAudioSpecificConfigObjectTypeSampleRateIndex16000 = 8,
};

@class VCAudioSpecificConfig;
@interface AVAudioFormat (AudioSpecificConfig)
- (VCAudioSpecificConfig *)audioSpecificConfig;
@end

@interface VCAudioSpecificConfig : NSObject

@property (nonatomic, assign) AudioFormatFlags objectType;
@property (nonatomic, assign) NSInteger sampleRate;
@property (nonatomic, assign) uint8_t channels;
@property (nonatomic, assign) BOOL frameLengthFlag; // 0 -> 960, 1 -> 1024
@property (nonatomic, assign) BOOL isDependOnCoreCoder;
@property (nonatomic, assign) BOOL isExtension;

- (instancetype)initWithData:(NSData *)data;
- (OSStatus)createAudioFormatDescription:(CMFormatDescriptionRef _Nullable * _Nullable)outputDescription;

- (NSData *)serialize;
- (void)deserialize;

- (NSData *)adtsDataForPacketLength:(NSUInteger)packetLength;
@end

NS_ASSUME_NONNULL_END
