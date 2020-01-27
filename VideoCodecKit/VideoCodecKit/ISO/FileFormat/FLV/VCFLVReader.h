//
//  VCFLVReader.h
//  VideoCodecKit
//
//  Created by CmST0us on 2019/1/30.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import "VCAssetReader.h"

NS_ASSUME_NONNULL_BEGIN
@class VCFLVReader;

@interface VCFLVVideoKeyFrameIndex : NSObject
@property (nonatomic, assign) NSUInteger position;
@property (nonatomic, assign) CMTime presentationTime;
@end

@interface VCFLVReader : VCAssetReader

@property (nonatomic, readonly) BOOL isReading;

@property (nonatomic, readonly) NSArray<VCFLVVideoKeyFrameIndex *> *keyFrameIndex;
// 必须调用createSeekTable之后才能获取到时长
// [TODO]: 使用meta tag 获取时长
@property (nonatomic, readonly) CMTime duration;

- (nullable instancetype)initWithURL:(NSURL *)url;

- (void)createSeekTable;

- (void)starAsyncReading;
- (void)startReading;
- (void)stopReading;

- (void)seekToTime:(CMTime)time;
@end

@interface NSArray (VCFLVReaderSeek)
- (nullable VCFLVVideoKeyFrameIndex *)indexOfTime:(CMTime)time;
@end
NS_ASSUME_NONNULL_END
