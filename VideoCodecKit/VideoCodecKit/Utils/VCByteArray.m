//
//  VCByteArray.m
//  VideoCodecKit
//
//  Created by CmST0us on 2019/1/19.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "VCByteArray.h"

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

@implementation VCByteArray

- (void)writing:(VCByteArrayWriterBlock)block {
    VCByteArrayWriter *writer = [[VCByteArrayWriter alloc] init];
    writer.target = self;
    block(writer);
}

- (void)writeDouble:(double)value {
    
}

- (void)writeFloat:(float)value {
    
}

- (void)writeBytes:(NSData *)value {
    
}

- (void)writeInt8:(int8_t)value {
    
}

- (void)writeInt16:(int16_t)value {
    
}

- (void)writeInt24:(int32_t)value {
    
}

- (void)writeInt32:(int32_t)value {
    
}

- (void)writeUInt8:(uint8_t)value {
    
}

- (void)writeUInt16:(uint16_t)value {
    
}

- (void)writeUInt24:(uint32_t)value {
    
}

- (void)writeUInt32:(uint32_t)value {
    
}

- (int8_t)readInt8 {
    return 0;
}

- (int16_t)readInt16 {
    return 0;
}

- (int32_t)readInt24 {
    return 0;
}

- (int32_t)readInt32 {
    return 0;
}

- (uint8_t)readUInt8 {
    return 0;
}

- (uint16_t)readUInt16 {
    return 0;
}

- (uint32_t)readUInt24 {
    return 0;
}

- (uint32_t)readUInt32 {
    return 0;
}

- (double)readDouble {
    return 0;
}

- (float)readFloat {
    return 0;
}

- (NSData *)readBytes:(NSInteger)length {
    return nil;
}

- (NSString *)readUTF8 {
    return nil;
}

- (NSString *)readUTF8Bytes:(NSInteger)length {
    return nil;
}


@end
