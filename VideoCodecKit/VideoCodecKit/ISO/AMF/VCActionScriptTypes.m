//
//  VCActionScriptTypes.m
//  VideoCodecKit
//
//  Created by CmST0us on 2019/2/12.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "VCByteArray.h"
#import "VCActionScriptTypes.h"
#import "VCAMF0Serialization.h"

@implementation VCActionScriptType

- (uint8_t)type {
    return VCAMF0TypeMarkerUndefined;
}

-(id)value {
    return [VCActionScriptUndefined undefined];
}

+ (instancetype)deserializeFromByteArray:(VCByteArray *)byteArray {
    VCAMF0TypeMarker type = [byteArray readUInt8];
    switch (type) {
        case VCAMF0TypeMarkerNumber:
            return [VCActionScriptType deserializeNumberFromByteArray:byteArray];
        case VCAMF0TypeMarkerBoolean:
            return [VCActionScriptType deserializeBoolFromByteArray:byteArray];
        case VCAMF0TypeMarkerString:
            return [VCActionScriptType deserializeStringFromArray:byteArray isLongString:NO];
        case VCAMF0TypeMarkerLongString:
            return [VCActionScriptType deserializeStringFromArray:byteArray isLongString:YES];
        case VCAMF0TypeMarkerObject:
            return [VCActionScriptType deserializeObjectFromByteArray:byteArray];
        case VCAMF0TypeMarkerNull:
            return [VCActionScriptType deserializeNullFromByteArray:byteArray];
        case VCAMF0TypeMarkerUndefined:
            return [VCActionScriptType deserializeUndefinedFromByteArray:byteArray];
        case VCAMF0TypeMarkerEcmaArray:
            return [VCActionScriptType deserializeECMAArrayFromByteArray:byteArray];
        case VCAMF0TypeMarkerObjectEnd:
            return [VCActionScriptType deserializeObjectEndFromByteArray:byteArray];
        case VCAMF0TypeMarkerStrictArray:
            return [VCActionScriptType deserializeStrictArrayFromByteArray:byteArray];
        case VCAMF0TypeMarkerDate:
            return [VCActionScriptType deserializeDateFromByteArray:byteArray];
        default:
            return [VCActionScriptUndefined undefined];
    }
    
}

+ (VCActionScriptNumber *)deserializeNumberFromByteArray:(VCByteArray *)byteArray {
    double value = [byteArray readDouble];
    NSNumber *number = [NSNumber numberWithDouble:value];
    VCActionScriptNumber *obj = [[VCActionScriptNumber alloc] init];
    obj.value = number;
    return obj;
}

+ (VCActionScriptBool *)deserializeBoolFromByteArray:(VCByteArray *)byteArray {
    BOOL value = [byteArray readUInt8];
    VCActionScriptBool *obj = [[VCActionScriptBool alloc] init];
    obj.value = value == 0 ? NO : YES;
    return obj;
}

+ (VCActionScriptString *)deserializeStringFromArray:(VCByteArray *)byteArray
                                        isLongString:(BOOL)isLongString {
    uint32_t len = isLongString ? [byteArray readUInt32] : [byteArray readInt16];
    if (len == 0) {
        return [VCActionScriptString emptyString];
    }
    NSString *value = [byteArray readUTF8Bytes:len];
    VCActionScriptString *obj = [[VCActionScriptString alloc] init];
    obj.value = value;
    return obj;
}

+ (VCActionScriptObject *)deserializeObjectFromByteArray:(VCByteArray *)byteArray {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSString *keyString = nil;
    do {
        keyString = [VCActionScriptType deserializeStringFromArray:byteArray isLongString:NO].value;
        VCActionScriptType *value = [VCActionScriptType deserializeFromByteArray:byteArray];
        if (keyString == nil ||
            [keyString length] == 0 ||
            [value isKindOfClass:[VCActionScriptObjectEnd class]]) {
            // empty
            break;
        }
        [dict setObject:value forKey:keyString];
    } while (keyString != nil &&
             keyString.length > 0);
    VCActionScriptObject *obj = [[VCActionScriptObject alloc] init];
    obj.value = dict;
    return obj;
}

+ (VCActionScriptNull *)deserializeNullFromByteArray:(VCByteArray *)byteArray {
    return [VCActionScriptNull null];
}

+ (VCActionScriptUndefined *)deserializeUndefinedFromByteArray:(VCByteArray *)byteArray {
    return [VCActionScriptUndefined undefined];
}

+ (VCActionScriptECMAArray *)deserializeECMAArrayFromByteArray:(VCByteArray *)byteArray {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    uint32_t associativeCount = [byteArray readUInt32];
    for (int i = 0; i < associativeCount; ++i) {
        VCActionScriptObject *object = [VCActionScriptType deserializeObjectFromByteArray:byteArray];
        [arr addObject:object];
    }
    VCActionScriptECMAArray *obj = [[VCActionScriptECMAArray alloc] init];
    obj.value = arr;
    return obj;
}

+ (VCActionScriptObjectEnd *)deserializeObjectEndFromByteArray:(VCByteArray *)byteArray {
    return [VCActionScriptObjectEnd objectEnd];
}

+ (VCActionScriptStrictArray *)deserializeStrictArrayFromByteArray:(VCByteArray *)byteArray {
    uint32_t arrayCount = [byteArray readUInt32];
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (int i = 0; i < arrayCount; ++i) {
        VCActionScriptType *type = [VCActionScriptType deserializeFromByteArray:byteArray];
        [arr addObject:type];
    }
    VCActionScriptStrictArray *obj = [[VCActionScriptStrictArray alloc] init];
    obj.value = arr;
    return obj;
}

+ (VCActionScriptDate *)deserializeDateFromByteArray:(VCByteArray *)byteArray {
    double timestamp = [byteArray readDouble];
    int16_t timeZone = [byteArray readInt16];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp / 1000];
    VCActionScriptDate *obj = [[VCActionScriptDate alloc] init];
    obj.value = date;
    obj.timeZone = timeZone;
    return obj;
}

- (void)serializeToArrayByte:(VCByteArray *)byteArray {
    [byteArray writeUInt8:VCAMF0TypeMarkerUndefined];
}

@end


#pragma mark - Number
@implementation VCActionScriptNumber
- (uint8_t)type {
    return VCAMF0TypeMarkerNumber;
}
@end

#pragma mark - Bool
@implementation VCActionScriptBool
- (uint8_t)type {
    return VCAMF0TypeMarkerBoolean;
}
@end

#pragma mark - String
@implementation VCActionScriptString
- (uint8_t)type {
    return [self isLongString] ? VCAMF0TypeMarkerLongString : VCAMF0TypeMarkerString;
}

- (NSString *)value {
    if (_value != nil) {
        return _value;
    }
    _value = @"";
    return _value;
}

- (BOOL)isLongString {
    if (self.value.length > UINT16_MAX) return YES;
    return NO;
}

+ (instancetype)emptyString {
    return [[VCActionScriptString alloc] init];
}

@end

#pragma mark - Object
@implementation VCActionScriptObject
- (uint8_t)type {
    return VCAMF0TypeMarkerObject;
}
- (NSMutableDictionary<NSString *,VCActionScriptType *> *)value {
    if (_value != nil) {
        return _value;
    }
    _value = [[NSMutableDictionary alloc] initWithCapacity:1];
    return _value;
}
@end

#pragma mark - Null
@implementation VCActionScriptNull
- (uint8_t)type {
    return VCAMF0TypeMarkerNull;
}

+ (instancetype)null {
    [[VCActionScriptNull alloc] init];
}
@end

#pragma mark - Undefined
@implementation VCActionScriptUndefined
- (uint8_t)type {
    return VCAMF0TypeMarkerUndefined;
}
+ (instancetype)undefined {
    [[VCActionScriptUndefined alloc] init];
}
@end

#pragma mark - ECMA Array
@implementation VCActionScriptECMAArray
- (NSMutableArray<VCActionScriptObject *> *)value {
    if (_value != nil) {
        return _value;
    }
    _value = [[NSMutableArray alloc] init];
}
- (uint8_t)type {
    return VCAMF0TypeMarkerEcmaArray;
}
@end

#pragma mark - Object End
@implementation VCActionScriptObjectEnd
- (uint8_t)type {
    return VCAMF0TypeMarkerObjectEnd;
}
+ (instancetype)objectEnd {
    return [[VCActionScriptObjectEnd alloc] init];
}
@end

#pragma mark - Strict Array
@implementation VCActionScriptStrictArray
- (NSMutableArray<VCActionScriptType *> *)value {
    if (_value != nil) {
        return _value;
    }
    _value = [[NSMutableArray alloc] init];
}
- (uint8_t)type {
    return VCAMF0TypeMarkerStrictArray;
}
@end

#pragma mark - Date
@implementation VCActionScriptDate
- (uint8_t)type {
    return VCAMF0TypeMarkerDate;
}
@end

#pragma mark - XML Document
@implementation VCActionScriptXMLDocument
- (uint8_t)type {
    return VCAMF0TypeMarkerXmlDocument;
}
@end
