//
//  VCByteArray.m
//  VideoCodecKit
//
//  Created by CmST0us on 2019/1/19.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "VCByteArray.h"

#define kVCByteArrayExceptionUserInfoKeyErrorType @"ErrorType"

@implementation VCByteArrayException

- (instancetype)initWithName:(NSExceptionName)aName reason:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo {
    self = [super initWithName:aName
                        reason:aReason
                      userInfo:aUserInfo];
    if (self) {
        NSNumber *errorType = aUserInfo[kVCByteArrayExceptionUserInfoKeyErrorType];
        if (errorType) {
            _errorType = errorType.integerValue;
        } else {
            _errorType = VCByteArrayErrorParse;
        }
    }
    return self;
}

+ (instancetype)eofException {
    return [[VCByteArrayException alloc] initWithName:NSRangeException
                                               reason:@"ByteArray's position is in the end.(EOF)"
                                             userInfo:@{kVCByteArrayExceptionUserInfoKeyErrorType: @(VCByteArrayErrorEOF)}];
}

+ (instancetype)parseException {
    return [[VCByteArrayException alloc] initWithName:NSGenericException
                                               reason:@"ByteArray parse error."
                                             userInfo:@{kVCByteArrayExceptionUserInfoKeyErrorType: @(VCByteArrayErrorParse)}];
}

@end

@implementation VCByteArrayWriter
- (VCByteArrayWriter * _Nonnull (^)(NSData * _Nonnull))writeBytes {
    return ^(NSData *value) {
        [self.target writeBytes:value];
        return self;
    };
}

- (VCByteArrayWriter * _Nonnull (^)(float))writeFloat {
    return ^(float value) {
        [self.target writeFloat:value];
        return self;
    };
}

- (VCByteArrayWriter * _Nonnull (^)(double))writeDouble {
    return ^(double value) {
        [self.target writeDouble:value];
        return self;
    };
}

- (VCByteArrayWriter * _Nonnull (^)(int8_t))writeInt8 {
    return ^(int8_t value) {
        [self.target writeInt8:value];
        return self;
    };
}

- (VCByteArrayWriter * _Nonnull (^)(int16_t))writeInt16 {
    return ^(int16_t value) {
        [self.target writeInt16:value];
        return self;
    };
}

- (VCByteArrayWriter * _Nonnull (^)(int32_t))writeInt24 {
    return ^(int32_t value) {
        [self.target writeInt24:value];
        return self;
    };
}

- (VCByteArrayWriter * _Nonnull (^)(int32_t))writeInt32 {
    return ^(int32_t value) {
        [self.target writeInt32:value];
        return self;
    };
}

- (VCByteArrayWriter * _Nonnull (^)(uint8_t))writeUInt8 {
    return ^(uint8_t value) {
        [self.target writeUInt8:value];
        return self;
    };
}

- (VCByteArrayWriter * _Nonnull (^)(uint16_t))writeUInt16 {
    return ^(uint16_t value) {
        [self.target writeUInt16:value];
        return self;
    };
}

- (VCByteArrayWriter * _Nonnull (^)(uint32_t))writeUInt24 {
    return ^(uint32_t value) {
        [self.target writeUInt24:value];
        return self;
    };
}

- (VCByteArrayWriter * _Nonnull (^)(uint32_t))writeUInt32 {
    return ^(uint32_t value) {
        [self.target writeUInt32:value];
        return self;
    };
}

@end

@interface VCByteArray ()
@property (nonatomic, strong) NSMutableData *mutableData;
@end

@implementation VCByteArray

- (instancetype)init {
    return [self initWithData:[NSData data]];
}

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        _mutableData = [[NSMutableData alloc] initWithData:data];
        _postion = 0;
    }
    return self;
}

- (NSInteger)length {
    return _mutableData.length;
}

- (void)setLength:(NSInteger)length {
    if (length < _mutableData.length) {
        _mutableData = [[_mutableData subdataWithRange:NSMakeRange(0, length)] mutableCopy];
    } else if (length > _mutableData.length) {
        [_mutableData increaseLengthBy:length - _mutableData.length];
    }
}

- (NSInteger)bytesAvailable {
    return _mutableData.length - _postion;
}

- (void)clear {
    _postion = 0;
    _mutableData = [NSMutableData data];
}

- (void)writing:(VCByteArrayWriterBlock)block {
    VCByteArrayWriter *writer = [[VCByteArrayWriter alloc] init];
    writer.target = self;
    block(writer);
}

- (void)writeBytes:(NSData *)value {
    if (_postion == _mutableData.length) {
        [_mutableData appendData:value];
        _postion = _mutableData.length;
        return;
    }
    // [TODO]: 理解理解这个MIN
    NSInteger length = MIN(_mutableData.length, value.length);
    [_mutableData replaceBytesInRange:NSMakeRange(_postion, length) withBytes:value.bytes length:value.length];
    if (length == _mutableData.length) {
        [_mutableData appendData:[value subdataWithRange:NSMakeRange(length, value.length)]];
    }
    _postion += value.length;
}

- (void)writeDouble:(double)value {
    CFSwappedFloat64 swappedDouble = CFConvertDoubleHostToSwapped(value);
    uint64_t v = swappedDouble.v;
    uint64_t sv = CFSwapInt64HostToBig(v);
    NSData *writeData = [[NSData alloc] initWithBytes:&sv length:kVCByteArraySizeOfDouble];
    [self writeBytes:writeData];
}

- (void)writeFloat:(float)value {
    CFSwappedFloat32 swappedFloat = CFConvertFloatHostToSwapped(value);
    uint32_t v = swappedFloat.v;
    [self writeUInt32:v];
}

- (void)writeInt8:(int8_t)value {
    int8_t v = value;
    NSData *data = [[NSData alloc] initWithBytes:&v length:kVCByteArraySizeOfInt8];
    [self writeBytes:data];
}

- (void)writeInt16:(int16_t)value {
    int16_t v = CFSwapInt16HostToBig(value);
    NSData *data = [[NSData alloc] initWithBytes:&v length:kVCByteArraySizeOfInt16];
    [self writeBytes:data];
}

- (void)writeInt24:(int32_t)value {
    int32_t v = CFSwapInt32HostToBig(value) >> 8;
    NSData *data = [[NSData alloc] initWithBytes:&v length:kVCByteArraySizeOfInt24];
    [self writeBytes:data];
}

- (void)writeInt32:(int32_t)value {
    int32_t v = CFSwapInt32HostToBig(value);
    NSData *data = [[NSData alloc] initWithBytes:&v length:kVCByteArraySizeOfInt32];
    [self writeBytes:data];
}

- (void)writeUInt8:(uint8_t)value {
    int8_t v = value;
    NSData *data = [[NSData alloc] initWithBytes:&v length:kVCByteArraySizeOfInt8];
    [self writeBytes:data];
}

- (void)writeUInt16:(uint16_t)value {
    uint16_t v = CFSwapInt16HostToBig(value);
    NSData *data = [[NSData alloc] initWithBytes:&v length:kVCByteArraySizeOfInt16];
    [self writeBytes:data];
}

- (void)writeUInt24:(uint32_t)value {
    uint32_t v = CFSwapInt32HostToBig(value) >> 8;
    NSData *data = [[NSData alloc] initWithBytes:&v length:kVCByteArraySizeOfInt24];
    [self writeBytes:data];
}

- (void)writeUInt32:(uint32_t)value {
    int32_t v = CFSwapInt32HostToBig(value);
    NSData *data = [[NSData alloc] initWithBytes:&v length:kVCByteArraySizeOfInt32];
    [self writeBytes:data];
}

- (int8_t)readInt8 {
    if (self.bytesAvailable < kVCByteArraySizeOfInt8) {
        @throw [VCByteArrayException eofException];
    }
    uint8_t *ptr = (uint8_t *)[_mutableData bytes];
    int8_t v = *(ptr + _postion);
    
    _postion += kVCByteArraySizeOfInt8;
    return v;
}

- (int16_t)readInt16 {
    if (self.bytesAvailable < kVCByteArraySizeOfInt16) {
        @throw [VCByteArrayException eofException];
    }
    uint8_t *ptr = (uint8_t *)[_mutableData bytes];
    int16_t *p = (int16_t *)(ptr + _postion);
    int16_t v = CFSwapInt16BigToHost(*p);
    
    _postion += kVCByteArraySizeOfInt16;
    return v;
}

- (int32_t)readInt24 {
    if (self.bytesAvailable < kVCByteArraySizeOfInt24) {
        @throw [VCByteArrayException eofException];
    }
    uint8_t *ptr = (uint8_t *)[_mutableData bytes];
    int32_t *p = (int32_t *)(ptr + _postion);
    int32_t v = CFSwapInt32BigToHost(*p << 8);
    _postion += kVCByteArraySizeOfInt24;
    return v;
}

- (int32_t)readInt32 {
    if (self.bytesAvailable < kVCByteArraySizeOfInt32) {
        @throw [VCByteArrayException eofException];
    }
    uint8_t *ptr = (uint8_t *)[_mutableData bytes];
    int32_t *p = (int32_t *)(ptr + _postion);
    int32_t v = CFSwapInt32BigToHost(*p);
    
    _postion += kVCByteArraySizeOfInt32;
    return v;
}

- (uint8_t)readUInt8 {
    if (self.bytesAvailable < kVCByteArraySizeOfInt8) {
        @throw [VCByteArrayException eofException];
    }
    uint8_t *ptr = (uint8_t *)[_mutableData bytes];
    uint8_t v = *(ptr + _postion);
    
    _postion += kVCByteArraySizeOfInt8;
    return v;
}

- (uint16_t)readUInt16 {
    if (self.bytesAvailable < kVCByteArraySizeOfInt16) {
        @throw [VCByteArrayException eofException];
    }
    uint8_t *ptr = (uint8_t *)[_mutableData bytes];
    uint16_t *p = (uint16_t *)(ptr + _postion);
    uint16_t v = CFSwapInt16BigToHost(*p);
    
    _postion += kVCByteArraySizeOfInt16;
    return v;
}

- (uint32_t)readUInt24 {
    if (self.bytesAvailable < kVCByteArraySizeOfInt24) {
        @throw [VCByteArrayException eofException];
    }
    uint8_t *ptr = (uint8_t *)[_mutableData bytes];
    uint32_t *p = (uint32_t *)(ptr + _postion);
    uint32_t v = CFSwapInt32BigToHost(*p << 8);
    _postion += kVCByteArraySizeOfInt24;
    return v;
}

- (uint32_t)readUInt32 {
    if (self.bytesAvailable < kVCByteArraySizeOfInt32) {
        @throw [VCByteArrayException eofException];
    }
    uint8_t *ptr = (uint8_t *)[_mutableData bytes];
    uint32_t *p = (uint32_t *)(ptr + _postion);
    uint32_t v = CFSwapInt32BigToHost(*p);
    
    _postion += kVCByteArraySizeOfInt32;
    return v;
}

- (double)readDouble {
    if (self.bytesAvailable < kVCByteArraySizeOfDouble) {
        @throw [VCByteArrayException eofException];
    }
    uint8_t *ptr = (uint8_t *)[_mutableData bytes];
    uint64_t *p = (uint64_t *)(ptr + _postion);
    uint64_t v = CFSwapInt64BigToHost(*p);
    
    CFSwappedFloat64 swappedDouble;
    swappedDouble.v = v;
    
    double doubleValue = CFConvertFloat64SwappedToHost(swappedDouble);
    _postion += kVCByteArraySizeOfDouble;
    return doubleValue;
}

- (float)readFloat {
    if (self.bytesAvailable < kVCByteArraySizeOfFloat) {
        @throw [VCByteArrayException eofException];
    }
    uint8_t *ptr = (uint8_t *)[_mutableData bytes];
    uint32_t *p = (uint32_t *)(ptr + _postion);
    uint32_t v = CFSwapInt32BigToHost(*p);
    
    CFSwappedFloat32 swappedFloat;
    swappedFloat.v = v;
    
    double floatValue = CFConvertFloat32SwappedToHost(swappedFloat);
    _postion += kVCByteArraySizeOfFloat;
    return floatValue;
}

- (NSData *)readBytes:(NSInteger)length {
    if (self.bytesAvailable < length) {
        @throw [VCByteArrayException eofException];
    }
    _postion += length;
    return [_mutableData subdataWithRange:NSMakeRange(_postion - length, length)];
}

- (NSString *)readUTF8 {
    @try {
        return [self readUTF8Bytes:[self readUInt16]];
    } @catch (NSException *exception) {
        @throw exception;
    } @finally {
        
    }
    return nil;
}

- (NSString *)readUTF8Bytes:(NSInteger)length {
    if (self.bytesAvailable < length) {
        @throw [VCByteArrayException eofException];
    }
    
    NSData *subData = [_mutableData subdataWithRange:NSMakeRange(_postion, length)];
    NSString *s = [[NSString alloc] initWithData:subData encoding:NSUTF8StringEncoding];
    if (s == NULL) {
        @throw [VCByteArrayException parseException];
    }
    return s;
}

- (NSData *)data {
    return [_mutableData copy];
}

@end
