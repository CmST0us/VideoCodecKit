//
//  VCH264Image.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/16.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import "VCH264Image.h"

CONST_STRING(kVCBaseImageUserInfoFrameIndexKey);

@interface VCH264Image ()

@end

@implementation VCH264Image
- (instancetype)initWithWidth:(NSUInteger)width
                       height:(NSUInteger)height {

    self = [super init];
    if (self) {
        self.width = width;
        self.height = height;
        _sliceType = VCH264SliceTypeNone;
    }
    return self;
}


- (void)createLumaDataWithSize:(NSUInteger)size
                   AndLineSize:(NSUInteger)lineSize {
    _lumaSize = size;
    _luma = (uint8_t *)malloc(_lumaSize);
    _lumaLineSize = lineSize;
    memset(_luma, 0, size);
}

- (void)createChromaBDataWithSize:(NSUInteger)size
                      AndLineSize:(NSUInteger)lineSize {
    _chromaBSize = size;
    _chromaB = (uint8_t *)malloc(_chromaBSize);
    _chromaBLineSize = lineSize;
    memset(_chromaB, 0, size);
}

- (void)createChromaRDataWithSize:(NSUInteger)size
                      AndLineSize:(NSUInteger)lineSize {
    _chromaRSize = size;
    _chromaR = (uint8_t *)malloc(_chromaRSize);
    _chromaRLineSize = lineSize;
    memset(_chromaR, 0, size);
}

- (NSData *)yuv420pPlaneData {
    return nil;
}

- (NSData *)nv12PlaneData {
    return nil;
}


- (void)dealloc {
    if (self.luma != nil) {
        free(self.luma);
        self.luma = nil;
        self.lumaSize = 0;
    }
    
    if (self.chromaB != nil) {
        free(self.chromaB);
        self.chromaB = nil;
        self.chromaBSize = 0;
    }
    
    if (self.chromaR != nil) {
        free(self.chromaR);
        self.chromaR = nil;
        self.chromaRSize = 0;
    }
}

@end
