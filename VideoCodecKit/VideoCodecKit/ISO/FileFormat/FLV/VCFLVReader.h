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

@protocol VCFLVReaderDelegate <NSObject>
- (void)reader:(VCFLVReader *)reader didGetVideoFormatDescription:(CMFormatDescriptionRef)formatDescription;
- (void)reader:(VCFLVReader *)reader didGetVideoSampleBuffer:(VCSampleBuffer *)sampleBuffer;
- (void)reader:(VCFLVReader *)reader didGetAudioFormatDescription:(CMFormatDescriptionRef)formatDescription;
- (void)reader:(VCFLVReader *)reader didGetAudioSampleBuffer:(VCSampleBuffer *)sampleBuffer;
@end

@class VCSampleBuffer;
@interface VCFLVReader : NSObject
@property (nonatomic, weak) id<VCFLVReaderDelegate> delegate;
- (nullable instancetype)initWithURL:(NSURL *)url;

- (void)starAsyncRead;
- (void)startRead;
@end

NS_ASSUME_NONNULL_END
