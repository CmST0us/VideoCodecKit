//
//  VCAVCConfigurationRecord.m
//  VideoCodecKit
//
//  Created by CmST0us on 2019/1/19.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "VCAVCConfigurationRecord.h"
#import "VCByteArray.h"
@interface VCAVCConfigurationRecord ()
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSMutableArray<NSData *> *sequenceParameterSets;
@property (nonatomic, strong) NSMutableArray<NSData *> *pictureParameterSets;
@property (nonatomic, strong) NSMutableArray<NSData *> *sequenceParameterSetExt;
@end

@implementation VCAVCConfigurationRecord

- (instancetype)initWithFormatDescription:(CMFormatDescriptionRef)formatDescription {
    NSDictionary *extension = (__bridge NSDictionary *)CMFormatDescriptionGetExtensions(formatDescription);
    if (extension == nil) {
        return nil;
    }
    NSDictionary *atoms = extension[(__bridge NSString *)kCMFormatDescriptionExtension_SampleDescriptionExtensionAtoms];
    if (atoms == nil) {
        return nil;
    }
    NSData *avc = atoms[@"avcC"];
    if (avc == nil) {
        return nil;
    }
    
    return [self initWithData:avc];
}

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        _data = data;
        _sequenceParameterSets = [NSMutableArray array];
        _pictureParameterSets = [NSMutableArray array];
        _sequenceParameterSetExt = [NSMutableArray array];
        @try {
            VCByteArray *array = [[VCByteArray alloc] initWithData:data];
            if ([array readUInt8] != 1) return nil;
            
            _AVCProfileIndication = [array readUInt8];
            _profileCompatibility = [array readUInt8];
            _AVCLevelIndication = [array readUInt8];
            _lengthSizeMinusOne = [array readUInt8] & 0x03;
            _numOfSequenceParameterSets = [array readUInt8] & 0x1F;
            
            for (int i = 0; i < _numOfSequenceParameterSets; ++i) {
                uint16_t sequenceParameterSetLength = [array readUInt16];
                NSData *sequenceParameterSetNALUnit = [array readBytes:sequenceParameterSetLength];
                [_sequenceParameterSets addObject:sequenceParameterSetNALUnit];
            }
            
            _numOfPictureParameterSets = [array readUInt8];
            for (int i = 0; i < _numOfPictureParameterSets; ++i) {
                uint16_t pictureParameterSetLength = [array readUInt16];
                NSData *pictureParameterSetNALUnit = [array readBytes:pictureParameterSetLength];
                [_pictureParameterSets addObject:pictureParameterSetNALUnit];
            }
            
            // 有些文件并不符合规范....
            if (_AVCProfileIndication == 100 ||
                _AVCProfileIndication == 110 ||
                _AVCProfileIndication == 122 ||
                _AVCProfileIndication == 144) {
                _chromaFormat = [array readUInt8] & 0x03;
                _bitDepthLumaMinus8 = [array readUInt8] & 0x1F;
                _bitDepthChromaMinus8 = [array readUInt8] & 0x1F;
                _numOfSequenceParameterSetExt = [array readUInt8];
                
                for (int i = 0; i < _numOfSequenceParameterSetExt; i++) {
                    uint16_t sequenceParameterSetExtLength = [array readUInt16];
                    NSData *sequenceParameterSetExtNALUnit = [array readBytes:sequenceParameterSetExtLength];
                    [_sequenceParameterSetExt addObject:sequenceParameterSetExtNALUnit];
                }
            }
            
        } @catch (NSException *exception) {
            if (_sequenceParameterSets.count > 0 ||
                _pictureParameterSets.count > 0) {
                return self;
            }
            return nil;
        }
    }
    return self;
}

- (NSInteger)naluLength {
    return _lengthSizeMinusOne + 1;
}

- (OSStatus)createFormatDescription:(CMVideoFormatDescriptionRef *)outFormatDescription {
    // Only Support First SPS PPS
    if (!(_sequenceParameterSets.count > 0 &&
        _pictureParameterSets.count > 0)) {
        return -1;
    }
    NSData *firstSPSData = _sequenceParameterSets[0];
    NSData *firstPPSData = _pictureParameterSets[0];
    
    const uint8_t *parameterSets[] = {
        (const uint8_t *)[firstSPSData bytes],
        (const uint8_t *)[firstPPSData bytes],
    };
    
    size_t parameterSetSizes[] = {
        firstSPSData.length,
        firstPPSData.length
    };
    
    return CMVideoFormatDescriptionCreateFromH264ParameterSets(kCFAllocatorDefault,
                                                               2, parameterSets, parameterSetSizes, (int)[self naluLength], outFormatDescription);
}

@end
