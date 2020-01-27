//
//  VCAssetReader.m
//  VideoCodecKit
//
//  Created by CmST0us on 2020/1/27.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import "VCAssetReader.h"

@implementation VCAssetReader

- (instancetype)init {
    self = [super init];
    if (self) {
        _audioFormatDescription = NULL;
        _videoFormatDescription = NULL;
        _sampleBufferQueueLock = [[NSCondition alloc] init];
    }
    return self;
}

- (VCSampleBuffer *)nextSampleBuffer {
    [_sampleBufferQueueLock lock];
    if (![_sampleBufferQueueLock waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:30]]){
        return nil;
    }
    VCSampleBuffer *buf = [_sampleBufferQueue firstObject];
    [_sampleBufferQueue removeObjectAtIndex:0];
    [_sampleBufferQueueLock unlock];
    return buf;
}

- (void)next {
    
}
@end
