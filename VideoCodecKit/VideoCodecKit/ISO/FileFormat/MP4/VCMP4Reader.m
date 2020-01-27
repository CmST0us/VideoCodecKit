//
//  VCMP4Reader.m
//  VideoCodecKit
//
//  Created by CmST0us on 2020/1/27.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "VCMP4Reader.h"

@interface VCMP4Reader ()
@property (nonatomic, strong) AVAssetReader *assetReader;
@property (nonatomic, strong) AVAssetReaderTrackOutput *audioOutput;
@property (nonatomic, strong) AVAssetReaderTrackOutput *videoOutput;
@end

@implementation VCMP4Reader

- (instancetype)initWithURL:(NSURL *)fileURL error:(NSError * _Nullable __autoreleasing *)error {
    self = [super init];
    if (self) {
        NSError *err = nil;
        do {
            AVAsset *asset = [AVAsset assetWithURL:fileURL];
            AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
            AVAssetTrack *audioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
            
            _assetReader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
            if (error != nil||
                _assetReader == nil) {
                err = error;
                break;
            }
            
            if (videoTrack) {
                _videoOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:videoTrack outputSettings:@{
                    
                }];
            }
            if (audioTrack) {
                _audioOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:audioTrack outputSettings:@{
                    
                }];
            }
            
        } while (0);
        if (*error != nil) {
            *error = err;
        }
        if (err == nil) {
            return self;
        }
    }
}

@end
