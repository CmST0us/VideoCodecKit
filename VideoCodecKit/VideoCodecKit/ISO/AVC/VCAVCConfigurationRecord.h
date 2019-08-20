//
//  VCAVCConfigurationRecord.h
//  VideoCodecKit
//
//  Created by CmST0us on 2019/1/19.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

NS_ASSUME_NONNULL_BEGIN
// reference: ISO/IEC 14496-15 2010
@interface VCAVCConfigurationRecord : NSObject
@property (nonatomic, readonly) uint8_t AVCProfileIndication;
@property (nonatomic, readonly) uint8_t profileCompatibility;
@property (nonatomic, readonly) uint8_t AVCLevelIndication;
@property (nonatomic, readonly) uint8_t lengthSizeMinusOne;
@property (nonatomic, readonly) uint8_t numOfSequenceParameterSets;
@property (nonatomic, readonly) uint8_t numOfPictureParameterSets;

@property (nonatomic, readonly) uint8_t chromaFormat;
@property (nonatomic, readonly) uint8_t bitDepthLumaMinus8;
@property (nonatomic, readonly) uint8_t bitDepthChromaMinus8;
@property (nonatomic, readonly) uint8_t numOfSequenceParameterSetExt;

- (nullable instancetype)initWithData:(NSData *)data;

- (NSInteger)naluLength;
- (OSStatus)createFormatDescription:(CMVideoFormatDescriptionRef *)outFormatDescription;

@end

NS_ASSUME_NONNULL_END
