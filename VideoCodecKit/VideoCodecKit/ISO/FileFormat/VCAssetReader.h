//
//  VCAssetReader.h
//  VideoCodecKit
//
//  Created by CmST0us on 2020/1/27.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import "VCSampleBuffer.h"

NS_ASSUME_NONNULL_BEGIN

@class VCAssetReader;

@protocol VCAssetReaderDelegate <NSObject>
- (void)reader:(VCAssetReader *)reader didGetVideoFormatDescription:(CMFormatDescriptionRef)formatDescription;
- (void)reader:(VCAssetReader *)reader didGetVideoSampleBuffer:(VCSampleBuffer *)sampleBuffer;
- (void)reader:(VCAssetReader *)reader didGetAudioFormatDescription:(CMFormatDescriptionRef)formatDescription;
- (void)reader:(VCAssetReader *)reader didGetAudioSampleBuffer:(VCSampleBuffer *)sampleBuffer;
- (void)readerDidReachEOF:(VCAssetReader *)reader;
@end

@interface VCAssetReader : NSObject {
@protected
    CMFormatDescriptionRef _videoFormatDescription;
    CMFormatDescriptionRef _audioFormatDescription;
    NSMutableArray<VCSampleBuffer *> *_sampleBufferQueue;
    NSCondition *_sampleBufferQueueLock;
}

@property (nonatomic, weak) id<VCAssetReaderDelegate> delegate;

@property (nonatomic, readonly) CMFormatDescriptionRef videoFormatDescription;
@property (nonatomic, readonly) CMFormatDescriptionRef audioFormatDescription;

- (nullable VCSampleBuffer *)nextSampleBuffer;
- (void)next;

@end

NS_ASSUME_NONNULL_END
