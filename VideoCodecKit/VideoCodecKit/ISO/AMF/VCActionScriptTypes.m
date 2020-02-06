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
        case VCAMF0TypeMarkerMovieClip:
        case VCAMF0TypeMarkerReference:
        case VCAMF0TypeMarkerUnsupported:
        case VCAMF0TypeMarkerRecordset:
        case VCAMF0TypeMarkerXmlDocument:
        case VCAMF0TypeMarkerTypedObject:
        case VCAMF0TypeMarkerAvmplusObject:
            NSAssert(NO, @"Unsupported Type Marker");
    }
    NSAssert(NO, @"Unsupported Type Marker");
    return nil;
}

+ (VCActionScriptNumber *)deserializeNumberFromByteArray:(VCByteArray *)byteArray {
    double value = [byteArray readDouble];
    NSNumber *number = [NSNumber numberWithDouble:value];
    return [VCActionScriptNumber asTypeWithNumber:number];
}

+ (VCActionScriptBool *)deserializeBoolFromByteArray:(VCByteArray *)byteArray {
    BOOL value = [byteArray readUInt8];
    return [VCActionScriptBool asTypeWithBool:value == 0 ? NO : YES];
}

+ (VCActionScriptString *)deserializeStringFromArray:(VCByteArray *)byteArray
                                        isLongString:(BOOL)isLongString {
    uint32_t len = isLongString ? [byteArray readUInt32] : [byteArray readInt16];
    if (len == 0) {
        return [VCActionScriptString emptyString];
    }
    NSString *value = [byteArray readUTF8Bytes:len];
    return [VCActionScriptString asTypeWithString:value];
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
    return [VCActionScriptObject asTypeWithDictionary:dict];
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
    return [VCActionScriptECMAArray asTypeWithArray:arr];
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
    return [VCActionScriptStrictArray asTypeWithArray:arr];
}

+ (VCActionScriptDate *)deserializeDateFromByteArray:(VCByteArray *)byteArray {
    double timestamp = [byteArray readDouble];
    int16_t timeZone = [byteArray readInt16];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp / 1000];
    return [VCActionScriptDate asTypeWithDate:date timeZone:timeZone];
}

+ (VCActionScriptXMLDocument *)deserializeXMLDocumentFromByteArray:(VCByteArray *)byteArray {
    NSString *str = [VCActionScriptType deserializeStringFromArray:byteArray isLongString:YES].value;
    return [VCActionScriptXMLDocument asTypeWithString:str];
}

- (void)serializeTypeMarkToArrayByte:(VCByteArray *)byteArray {
    [byteArray writeUInt8:self.type];
}

- (void)serializeToArrayByte:(VCByteArray *)byteArray {
    
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@", self.value];
}
@end


#pragma mark - Number
@implementation VCActionScriptNumber
- (NSNumber *)value {
    if (_value != nil) {
        return _value;
    }
    _value = @(0);
    return _value;
}

- (uint8_t)type {
    return VCAMF0TypeMarkerNumber;
}

- (void)serializeToArrayByte:(VCByteArray *)byteArray {
    [byteArray writing:^(VCByteArrayWriter * _Nonnull writer) {
        writer.writeDouble(self.value.doubleValue);
    }];
}

+ (instancetype)asTypeWithNumber:(NSNumber *)aNumber {
    VCActionScriptNumber *v = [[VCActionScriptNumber alloc] init];
    v.value = aNumber;
    return v;
}
@end

@implementation NSNumber (VCActionScriptNumber)
- (VCActionScriptNumber *)asNumber {
    return [VCActionScriptNumber asTypeWithNumber:self];
}
@end

#pragma mark - Bool
@implementation VCActionScriptBool
- (uint8_t)type {
    return VCAMF0TypeMarkerBoolean;
}
- (void)serializeToArrayByte:(VCByteArray *)byteArray {
    [byteArray writing:^(VCByteArrayWriter * _Nonnull writer) {
        writer.writeUInt8(self.value ? 1 : 0);
    }];
}

+ (instancetype)asTypeWithBool:(BOOL)aBool {
    VCActionScriptBool *v = [[VCActionScriptBool alloc] init];
    v.value = aBool;
    return v;
}
@end

@implementation NSNumber (VCActionScriptBool)
- (VCActionScriptBool *)asBool {
    return [VCActionScriptBool asTypeWithBool:self.boolValue];
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

- (void)serializeToArrayByte:(VCByteArray *)byteArray {
    [byteArray writing:^(VCByteArrayWriter * _Nonnull writer) {
        if (self.value.length == 0) {
            writer.writeUInt16(0);
            return;
        }
        NSData *data = [self.value dataUsingEncoding:NSUTF8StringEncoding];
        if ([self isLongString]) {
            writer.writeUInt32((uint32_t)data.length).writeBytes(data);
        } else {
            writer.writeUInt16(data.length).writeBytes(data);
        }
    }];
}

+ (instancetype)emptyString {
    return [[VCActionScriptString alloc] init];
}

+ (instancetype)asTypeWithString:(NSString *)aString {
    VCActionScriptString *str = [[VCActionScriptString alloc] init];
    str.value = aString;
    return str;
}
@end

@implementation NSString (VCActionScriptString)
- (VCActionScriptString *)asString {
    return [VCActionScriptString asTypeWithString:self];
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

- (void)serializeToArrayByte:(VCByteArray *)byteArray {
    for (NSString *key in [self.value allKeys]) {
        VCActionScriptType *value = self.value[key];
        VCActionScriptString *str = [[VCActionScriptString alloc] init];
        str.value = key;
        [str serializeToArrayByte:byteArray];
        [value serializeTypeMarkToArrayByte:byteArray];
        [value serializeToArrayByte:byteArray];
    }
    [[VCActionScriptString emptyString] serializeToArrayByte:byteArray];
    [[VCActionScriptObjectEnd objectEnd] serializeTypeMarkToArrayByte:byteArray];
}

+ (instancetype)asTypeWithDictionary:(NSDictionary *)aDict {
    VCActionScriptObject *v = [[VCActionScriptObject alloc] init];
    v.value = [[NSMutableDictionary alloc] initWithDictionary:aDict];
    return v;
}
@end

#pragma mark - Null
@implementation VCActionScriptNull
- (uint8_t)type {
    return VCAMF0TypeMarkerNull;
}

+ (instancetype)null {
    return [[VCActionScriptNull alloc] init];
}
@end

@implementation NSNull (VCActionScriptNull)
+ (VCActionScriptNull *)asNull {
    return [VCActionScriptNull null];
}
@end

#pragma mark - Undefined
@implementation VCActionScriptUndefined
- (uint8_t)type {
    return VCAMF0TypeMarkerUndefined;
}
+ (instancetype)undefined {
    return [[VCActionScriptUndefined alloc] init];
}
@end

#pragma mark - ECMA Array
@implementation VCActionScriptECMAArray
- (NSMutableArray<VCActionScriptObject *> *)value {
    if (_value != nil) {
        return _value;
    }
    _value = [[NSMutableArray alloc] init];
    return _value;
}
- (uint8_t)type {
    return VCAMF0TypeMarkerEcmaArray;
}

- (void)serializeToArrayByte:(VCByteArray *)byteArray {
    [byteArray writeUInt32:(uint32_t)self.value.count];
    for (VCActionScriptObject *obj in self.value) {
        [obj serializeToArrayByte:byteArray];
    }
}

+ (instancetype)asTypeWithArray:(NSArray<VCActionScriptObject *> *)aArray {
    VCActionScriptECMAArray *v = [[VCActionScriptECMAArray alloc] init];
    v.value = [[NSMutableArray alloc] initWithArray:aArray];
    return v;
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
    return _value;
}
- (uint8_t)type {
    return VCAMF0TypeMarkerStrictArray;
}

- (void)serializeToArrayByte:(VCByteArray *)byteArray {
    [byteArray writeUInt32:(uint32_t)self.value.count];
    for (VCActionScriptType *obj in self.value) {
        [obj serializeTypeMarkToArrayByte:byteArray];
        [obj serializeToArrayByte:byteArray];
    }
}

+ (instancetype)asTypeWithArray:(NSArray<VCActionScriptType *> *)aArray {
    VCActionScriptStrictArray *v = [[VCActionScriptStrictArray alloc] init];
    v.value = [[NSMutableArray alloc] initWithArray:aArray];
    return v;
}
@end

#pragma mark - Date
@implementation VCActionScriptDate
- (uint8_t)type {
    return VCAMF0TypeMarkerDate;
}

- (void)serializeToArrayByte:(VCByteArray *)byteArray {
    [byteArray writing:^(VCByteArrayWriter * _Nonnull writer) {
        writer.writeDouble([self.value timeIntervalSince1970] * 1000).writeInt16(self.timeZone);
    }];
}

+ (instancetype)asTypeWithDate:(NSDate *)aDate timeZone:(int16_t)timeZone {
    VCActionScriptDate *v = [[VCActionScriptDate alloc] init];
    v.value = aDate;
    v.timeZone = timeZone;
    return v;
}
@end

#pragma mark - XML Document
@implementation VCActionScriptXMLDocument
- (uint8_t)type {
    return VCAMF0TypeMarkerXmlDocument;
}

- (void)serializeToArrayByte:(VCByteArray *)byteArray {
    [byteArray writing:^(VCByteArrayWriter * _Nonnull writer) {
        NSData *data = [self.value dataUsingEncoding:NSUTF8StringEncoding];
        writer.writeUInt32((uint32_t)data.length).writeBytes(data);
    }];
}

+ (instancetype)asTypeWithString:(NSString *)aString {
    VCActionScriptXMLDocument *v = [[VCActionScriptXMLDocument alloc] init];
    v.value = aString;
    return v;
}
@end
