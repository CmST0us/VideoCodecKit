//
//  VCMP4Reader.h
//  VideoCodecKit
//
//  Created by CmST0us on 2020/1/27.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import "VCAssetReader.h"

NS_ASSUME_NONNULL_BEGIN

@interface VCMP4Reader : VCAssetReader

@property (nonatomic, strong) NSError *lastError;

- (instancetype)init NS_UNAVAILABLE;
- (nullable instancetype)initWithURL:(NSURL *)fileURL error:(NSError * _Nullable * _Nullable)error;

@end

NS_ASSUME_NONNULL_END
