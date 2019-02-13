//
//  VCAMF0Serialization.m
//  VideoCodecKit
//
//  Created by CmST0us on 2019/2/12.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "VCAMF0Serialization.h"
#import "VCActionScriptTypes.h"
#import "VCByteArray.h"

@interface VCAMF0Serialization ()
@property (nonatomic, strong) VCByteArray *array;
@end

@implementation VCAMF0Serialization

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        _array = [[VCByteArray alloc] initWithData:data];
    }
    return self;
}

- (VCAMF0Serialization *)serialize:(VCActionScriptType *)type {
    [type serializeTypeMarkToArrayByte:self.array];
    [type serializeToArrayByte:self.array];
    return self;
}

- (VCActionScriptType *)deserialize {
    return [VCActionScriptType deserializeFromByteArray:self.array];
}

@end
