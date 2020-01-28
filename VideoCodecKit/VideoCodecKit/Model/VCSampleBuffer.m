//
//  VCSampleBuffer.m
//  VideoCodecKit
//
//  Created by CmST0us on 2019/1/19.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "VCSampleBuffer.h"

@interface VCSampleBuffer ()
@property (nonatomic, assign) BOOL shouldFreeWhenDone;
@end

@implementation VCSampleBuffer

- (instancetype)initWithSampleBuffer:(CMSampleBufferRef)aSampleBuffer {
    return [self initWithSampleBuffer:aSampleBuffer freeWhenDone:YES];
}

- (instancetype)initWithSampleBuffer:(CMSampleBufferRef)aSampleBuffer freeWhenDone:(BOOL)shouldFreeWhenDone {
    self = [super init];
    if (self) {
        _sampleBuffer = aSampleBuffer;
        _shouldFreeWhenDone = shouldFreeWhenDone;
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

- (BOOL)keyFrame {
    CFArrayRef attach = CMSampleBufferGetSampleAttachmentsArray(_sampleBuffer, false);
    if (attach == NULL) {
        return YES;
    }
    CFDictionaryRef dict = CFArrayGetValueAtIndex(attach, 0);
    if (dict == NULL) {
        return YES;
    }
    BOOL keyFrame = !CFDictionaryContainsKey(dict, kCMSampleAttachmentKey_NotSync);
    return keyFrame;
}

- (AudioStreamBasicDescription)audioStreamBasicDescription {
    CMAudioFormatDescriptionRef audioFormat = CMSampleBufferGetFormatDescription(_sampleBuffer);
    return *CMAudioFormatDescriptionGetStreamBasicDescription(audioFormat);
}

- (NSData *)h264ParameterSetData {
    const uint8_t *outPtr = nil;
    size_t outSize = 0;
    uint8_t header[] = {0x00, 0x00, 0x00, 0x01};
    NSMutableData *data = [[NSMutableData alloc] init];
    OSStatus ret = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(self.formatDescription, 0, &outPtr, &outSize, NULL, NULL);
    if (ret != noErr) return nil;
    [data appendBytes:header length:4];
    [data appendBytes:outPtr length:outSize];
    
    ret = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(self.formatDescription, 1, &outPtr, &outSize, NULL, NULL);
    if (ret != noErr) return nil;
    [data appendBytes:header length:4];
    [data appendBytes:outPtr length:outSize];
    return data;
}

- (NSData *)dataBufferData {
    char *outPtr = nil;
    size_t outSize = 0;
    OSStatus ret = CMBlockBufferGetDataPointer(self.dataBuffer, 0, NULL, &outSize, &outPtr);
    if (ret != noErr) {
        return nil;
    }
    NSData *data = [[NSData alloc] initWithBytes:(void *)outPtr length:outSize];
    return data;
}

- (void)dealloc {
    if (_sampleBuffer &&
        _shouldFreeWhenDone) {
        CFRelease(_sampleBuffer);
        _sampleBuffer = NULL;
    }
}

@end
