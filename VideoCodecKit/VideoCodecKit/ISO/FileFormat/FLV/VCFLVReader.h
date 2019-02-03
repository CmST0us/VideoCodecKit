//
//  VCFLVReader.h
//  VideoCodecKit
//
//  Created by CmST0us on 2019/1/30.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

NS_ASSUME_NONNULL_BEGIN
@class VCFLVReader;
@class VCSampleBuffer;

@interface VCFLVVideoKeyFrameIndex : NSObject
@property (nonatomic, assign) NSUInteger position;
@property (nonatomic, assign) CMTime presentationTime;
@end

@protocol VCFLVReaderDelegate <NSObject>
- (void)reader:(VCFLVReader *)reader didGetVideoFormatDescription:(CMFormatDescriptionRef)formatDescription;
- (void)reader:(VCFLVReader *)reader didGetVideoSampleBuffer:(VCSampleBuffer *)sampleBuffer;
- (void)reader:(VCFLVReader *)reader didGetAudioFormatDescription:(CMFormatDescriptionRef)formatDescription;
- (void)reader:(VCFLVReader *)reader didGetAudioSampleBuffer:(VCSampleBuffer *)sampleBuffer;
- (void)readerDidReachEOF:(VCFLVReader *)reader;
@end

@class VCSampleBuffer;
@interface VCFLVReader : NSObject

@property (nonatomic, weak) id<VCFLVReaderDelegate> delegate;
@property (nonatomic, readonly) BOOL isReading;

@property (nonatomic, readonly) NSArray<VCFLVVideoKeyFrameIndex *> *keyFrameIndex;
// 必须调用reCreateSeekTable之后才能获取到时长
// [TODO]: 使用meta tag 获取时长
@property (nonatomic, readonly) CMTime duration;

- (nullable instancetype)initWithURL:(NSURL *)url;

- (void)reCreateSeekTable;

- (void)starAsyncReading;
- (void)startReading;

- (void)seekToTime:(CMTime)time;
@end

@interface NSArray (VCFLVReaderSeek)
- (nullable VCFLVVideoKeyFrameIndex *)indexOfTime:(CMTime)time;
@end
NS_ASSUME_NONNULL_END
