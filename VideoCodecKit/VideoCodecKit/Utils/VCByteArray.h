//
//  VCByteArray.h
//  VideoCodecKit
//
//  Created by CmST0us on 2019/1/19.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kVCByteArraySizeOfInt8 1
#define kVCByteArraySizeOfInt16 2
#define kVCByteArraySizeOfInt24 3
#define kVCByteArraySizeOfInt32 4
#define kVCByteArraySizeOfFloat 4
#define kVCByteArraySizeOfDouble 8

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, VCByteArrayError) {
    VCByteArrayErrorEOF,
    VCByteArrayErrorParse,
};

@interface VCByteArrayException : NSException
@property (nonatomic, readonly) VCByteArrayError errorType;

+ (instancetype)eofException;
+ (instancetype)parseException;
@end

@class VCByteArray;
@interface VCByteArrayWriter: NSObject
@property (nonatomic, strong) VCByteArray *target;
- (VCByteArrayWriter * (^)(uint8_t value))writeUInt8;
- (VCByteArrayWriter * (^)(int8_t value))writeInt8;
- (VCByteArrayWriter * (^)(uint16_t value))writeUInt16;
- (VCByteArrayWriter * (^)(int16_t value))writeInt16;
- (VCByteArrayWriter * (^)(uint32_t value))writeUInt24;
- (VCByteArrayWriter * (^)(int32_t value))writeInt24;
- (VCByteArrayWriter * (^)(uint32_t value))writeUInt32;
- (VCByteArrayWriter * (^)(uint32_t value))writeUInt32Little;
- (VCByteArrayWriter * (^)(int32_t value))writeInt32;
- (VCByteArrayWriter * (^)(double value))writeDouble;
- (VCByteArrayWriter * (^)(float value))writeFloat;
- (VCByteArrayWriter * (^)(NSData *value))writeBytes;
@end

typedef void(^VCByteArrayWriterBlock)(VCByteArrayWriter *writer);

@interface VCByteArray : NSObject
@property (nonatomic, readonly) NSData *data;
@property (nonatomic, assign) NSInteger postion;
@property (nonatomic, assign) NSInteger length;
@property (nonatomic, readonly) NSInteger bytesAvailable;

- (instancetype)initWithData:(NSData *)data NS_DESIGNATED_INITIALIZER;

- (uint8_t)readUInt8;
- (int8_t)readInt8;
- (uint16_t)readUInt16;
- (int16_t)readInt16;
- (uint32_t)readUInt24;
- (int32_t)readInt24;
- (uint32_t)readUInt32;
- (uint32_t)readUInt32Little;
- (int32_t)readInt32;
- (double)readDouble;
- (float)readFloat;
- (NSString *)readUTF8;
- (NSString *)readUTF8Bytes:(NSInteger)length;
- (NSData *)readBytes:(NSInteger)length;

- (void)writeUInt8:(uint8_t)value;
- (void)writeInt8:(int8_t)value;
- (void)writeUInt16:(uint16_t)value;
- (void)writeInt16:(int16_t)value;
- (void)writeUInt24:(uint32_t)value;
- (void)writeInt24:(int32_t)value;
- (void)writeUInt32:(uint32_t)value;
- (void)writeUInt32Little:(uint32_t)value;
- (void)writeInt32:(int32_t)value;
- (void)writeDouble:(double)value;
- (void)writeFloat:(float)value;
- (void)writeBytes:(NSData *)value;

- (void)writing:(VCByteArrayWriterBlock)block;
- (void)clear;
@end

NS_ASSUME_NONNULL_END
