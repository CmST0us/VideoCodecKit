//
//  VCBaseImage.m
//  VideoCodecKit
//
//  Created by CmST0us on 2018/10/21.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import "VCBaseImage.h"

@implementation VCBaseImage
@synthesize pixelBuffer = _pixelBuffer;

- (instancetype)init {
    self = [super init];
    if (self) {
        _userInfo = [NSMutableDictionary dictionary];
        _width = 0;
        _height = 0;
        _pixelBuffer = NULL;
    }
    return self;
}
- (instancetype)initWithPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    if (pixelBuffer == NULL) return nil;
    self = [self init];
    if (self) {
        _pixelBuffer = CVPixelBufferRetain(pixelBuffer);
        size_t planeCount = CVPixelBufferGetPlaneCount(_pixelBuffer);
        if (planeCount > 0) {
            _width = planeCount > 1 ? CVPixelBufferGetWidthOfPlane(_pixelBuffer, 0) : CVPixelBufferGetWidth(_pixelBuffer);
            _height = planeCount > 1 ? CVPixelBufferGetHeightOfPlane(_pixelBuffer, 0) : CVPixelBufferGetHeight(_pixelBuffer);
        }
    }
    return self;
}

- (void)dealloc {
    if (_pixelBuffer != NULL) {
        CVPixelBufferRelease(_pixelBuffer);
        _pixelBuffer = NULL;
    }
}
@end
