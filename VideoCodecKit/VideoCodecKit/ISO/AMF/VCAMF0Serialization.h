//
//  VCAMF0Serialization.h
//  VideoCodecKit
//
//  Created by CmST0us on 2019/2/12.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// reference: Action Message Format -- AMF 0

// see: 2.1 Types Overview
typedef NS_ENUM(uint8_t, VCAMF0TypeMarker) {
    VCAMF0TypeMarkerNumber = 0x00,
    VCAMF0TypeMarkerBoolean = 0x01,
    VCAMF0TypeMarkerString = 0x02,
    VCAMF0TypeMarkerObject = 0x03,
    VCAMF0TypeMarkerMovieClip = 0x04,       // reserved, not support
    VCAMF0TypeMarkerNull = 0x05,
    VCAMF0TypeMarkerUndefined = 0x06,
    VCAMF0TypeMarkerReference = 0x07,
    VCAMF0TypeMarkerEcmaArray = 0x08,
    VCAMF0TypeMarkerObjectEnd = 0x09,
    VCAMF0TypeMarkerStrictArray = 0x0A,
    VCAMF0TypeMarkerDate = 0x0B,
    VCAMF0TypeMarkerLongString = 0x0C,
    VCAMF0TypeMarkerUnsupported = 0x0D,
    VCAMF0TypeMarkerRecordset = 0x0E,       // reserved, not support
    VCAMF0TypeMarkerXmlDocument = 0x0F,
    VCAMF0TypeMarkerTypedObject = 0x10,
    VCAMF0TypeMarkerAvmplusObject = 0x11
};

@class VCActionScriptType;
@interface VCAMF0Serialization : NSObject
- (instancetype)initWithData:(NSData *)data;

#pragma mark - Serialize Method
- (VCAMF0Serialization *)serialize:(VCActionScriptType *)type;
#pragma mark - Deserialize Method
- (VCActionScriptType *)deserialize;

@end

NS_ASSUME_NONNULL_END
