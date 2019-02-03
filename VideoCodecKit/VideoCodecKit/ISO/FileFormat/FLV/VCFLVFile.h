//
//  VCFLVFile.h
//  VideoCodecKit
//
//  Created by CmST0us on 2019/1/30.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class VCFLVTag;
@interface VCFLVFile : NSObject

@property (nonatomic, readonly) uint8_t version;
@property (nonatomic, readonly) uint32_t dataOffset;
@property (nonatomic, strong) NSData *headerData;

@property (nonatomic, readonly) NSUInteger fileSize;
@property (nonatomic, readonly) NSUInteger currentTagOffsetInFile;
@property (nonatomic, assign) NSUInteger currentFileOffset;

- (nullable instancetype)initWithURL:(NSURL *)fileURL;
- (nullable VCFLVTag *)nextTag;

@end

NS_ASSUME_NONNULL_END
