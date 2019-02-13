//
//  VCActionScriptTypes.h
//  VideoCodecKit
//
//  Created by CmST0us on 2019/2/12.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class VCByteArray;
@interface VCActionScriptType: NSObject
@property (nonatomic, readonly) uint8_t type;
+ (instancetype)deserializeFromByteArray:(VCByteArray *)byteArray;
- (void)serializeToArrayByte:(VCByteArray *)byteArray;
- (id)value;
@end

// seealso: 2.2 Number Type
@interface VCActionScriptNumber: VCActionScriptType
@property (nonatomic, strong) NSNumber *value;
@end

// seealso: 2.3 Boolean Type
@interface VCActionScriptBool: VCActionScriptType
@property (nonatomic, assign) BOOL value;
@end

// seealso: 2.4 String Type
@interface VCActionScriptString: VCActionScriptType
@property (nonatomic, copy) NSString *value;
@property (nonatomic, getter=isLongString, readonly) BOOL longString;
- (BOOL)isLongString;
+ (instancetype)emptyString;
@end

// seealso: 2.5 Object Type
@interface VCActionScriptObject: VCActionScriptType
@property (nonatomic, strong) NSMutableDictionary<NSString *, VCActionScriptType *> *value;
@end

// seealso: 2.7 Null Type
@interface VCActionScriptNull: VCActionScriptType
+ (instancetype)null;
@end

// seealso: 2.8 Undefined Type
@interface VCActionScriptUndefined: VCActionScriptType
+ (instancetype)undefined;
@end

// seealso: 2.10 ECMA Array Type
@interface VCActionScriptECMAArray: VCActionScriptType
@property (nonatomic, strong) NSMutableArray<VCActionScriptObject *> *value;
@end

// seealso: 2.11 Object End Type
@interface VCActionScriptObjectEnd: VCActionScriptType
+ (instancetype)objectEnd;
@end

// sesalso: 2.12 Strict Array Type
@interface VCActionScriptStrictArray: VCActionScriptType
@property (nonatomic, strong) NSMutableArray<VCActionScriptType *> *value;
@end

// seealso: 2.13 Date Type
@interface VCActionScriptDate: VCActionScriptType
@property (nonatomic, strong) NSDate *value;
@property (nonatomic, assign) int16_t timeZone;
@end

@interface VCActionScriptXMLDocument: VCActionScriptType

@end


NS_ASSUME_NONNULL_END
