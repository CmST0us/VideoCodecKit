//
//  VCYUV422Image.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/16.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import "VCYUV422Image.h"

@implementation VCYUV422Image
- (instancetype)initWithWidth:(NSUInteger)width
                       height:(NSUInteger)height {

    self = [super self];
    if (self) {
        _width = width;
        _height = height;
    }
    return self;
}

- (void)createLumaDataWithSize:(NSUInteger)size {
    _lumaSize = size;
    _luma = (uint8_t *)malloc(_lumaSize);
}

- (void)createChromaBDataWithSize:(NSUInteger)size {
    _chromaBSize = size;
    _chromaB = (uint8_t *)malloc(_chromaBSize);
}

- (void)createChromaRDataWithSize:(NSUInteger)size {
    _chromaRSize = size;
    _chromaR = (uint8_t *)malloc(_chromaRSize);
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
