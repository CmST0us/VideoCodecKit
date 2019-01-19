//
//  VCSampleBuffer.m
//  VideoCodecKit
//
//  Created by CmST0us on 2019/1/19.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "VCSampleBuffer.h"

@implementation VCSampleBuffer

- (instancetype)initWithSampleBuffer:(CMSampleBufferRef)aSampleBuffer {
    self = [super init];
    if (self) {
        _sampleBuffer = aSampleBuffer;
    }
    return self;
}

- (CMBlockBufferRef)dataBuffer {
    return CMSampleBufferGetDataBuffer(_sampleBuffer);
}

- (void)setDataBuffer:(CMBlockBufferRef)dataBuffer {
    CMSampleBufferSetDataBuffer(_sampleBuffer, dataBuffer);
}

- (CVImageBufferRef)imageBuffer {
    return CMSampleBufferGetImageBuffer(_sampleBuffer);
}

- (CMItemCount)numberOfSamples {
    return CMSampleBufferGetNumSamples(_sampleBuffer);
}

- (CMTime)duration {
    return CMSampleBufferGetDuration(_sampleBuffer);
}

- (CMFormatDescriptionRef)formatDescription {
    return CMSampleBufferGetFormatDescription(_sampleBuffer);
}

- (CMTime)decodeTimeStamp {
    return CMSampleBufferGetDecodeTimeStamp(_sampleBuffer);
}

- (CMTime)presentationTimeStamp {
    return CMSampleBufferGetPresentationTimeStamp(_sampleBuffer);
}

- (void)dealloc {
    CFRelease(_sampleBuffer);
}

@end
