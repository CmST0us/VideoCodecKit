//
//  VCAudioSpecificConfig.h
//  VideoCodecKit
//
//  Created by CmST0us on 2019/1/31.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
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

@interface VCAudioSpecificConfig : NSObject

@property (nonatomic, readonly) AudioFormatFlags objectType;
@property (nonatomic, readonly) VCAudioSpecificConfigObjectTypeSampleRateIndex sampleRateIndex;
@property (nonatomic, readonly) NSInteger sampleRate;
@property (nonatomic, readonly) uint8_t channels;
@property (nonatomic, readonly) uint8_t frameLengthFlag;
@property (nonatomic, readonly) BOOL isDependOnCoreCoder;
@property (nonatomic, readonly) BOOL isExtension;

- (instancetype)initWithData:(NSData *)data;
- (OSStatus)createAudioFormatDescription:(CMFormatDescriptionRef _Nullable * _Nullable)outputDescription;

@end

NS_ASSUME_NONNULL_END
