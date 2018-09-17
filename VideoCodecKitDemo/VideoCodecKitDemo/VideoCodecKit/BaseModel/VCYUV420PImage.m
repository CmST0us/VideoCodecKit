//
//  VCYUV420PImage.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/16.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import "VCYUV420PImage.h"

@interface VCYUV420PImage ()

@end

@implementation VCYUV420PImage
- (instancetype)initWithWidth:(NSUInteger)width
                       height:(NSUInteger)height {

    self = [super self];
    if (self) {
        _width = width;
        _height = height;
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
    uint8_t *planeData = (uint8_t *)malloc(self.lumaSize + self.chromaBSize + self.chromaRSize);
    
    memcpy(planeData, self.luma, self.lumaSize);
    memcpy(planeData + self.lumaSize, self.chromaB, self.chromaBSize);
    memcpy(planeData + self.lumaSize + self.chromaBSize, self.chromaR, self.chromaRSize);
    NSData *data = [[NSData alloc] initWithBytes:planeData length:self.lumaSize + self.chromaBSize + self.chromaRSize];

    free(planeData);
    return data;
}

- (NSData *)nv12PlaneData {
    NSInteger planeSize = self.width * self.height * 3 / 2;
    uint8_t *planeData = (uint8_t *)malloc(planeSize);
    
    uint8_t *yData = planeData;
    uint8_t *uvData = planeData + self.width * self.height;
    
    memcpy(yData, self.luma, self.lumaLineSize * self.height);
    
    // UV 交叉储存！！！！
    for (int i = 0; i < self.height / 2; ++i) {
        for (int j = 0; j < self.width; j = j + 1) {
            // u
            uvData[i * self.width + j * 2] = self.chromaB[i * self.chromaBLineSize + j];
            // v
            uvData[i * self.width + j * 2 + 1] = self.chromaR[i * self.chromaRLineSize + j];
        }
    }
    
    NSData *data = [[NSData alloc] initWithBytes:planeData length:planeSize];
    free(planeData);
    return data;
}

- (CVPixelBufferRef)pixelBuffer {
    
    CVPixelBufferRef pixelBuffer = NULL;
    
    NSDictionary *attr = @{
                           (id)kCVPixelBufferOpenGLCompatibilityKey: @(YES),
                           };
    
    CVPixelBufferCreate(kCFAllocatorDefault,
                        self.width,
                        self.height,
                        kCVPixelFormatType_420YpCbCr8BiPlanarFullRange, (__bridge CFDictionaryRef)attr, &pixelBuffer);
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    uint8_t *yData = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    uint8_t *uvData = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
    
    memcpy(yData, self.luma, self.lumaLineSize * self.height);
    
    // UV 交叉储存！！！！
    for (int i = 0; i < self.height / 2; ++i) {
        for (int j = 0; j < self.width; j = j + 1) {
            // u
            uvData[i * self.width + j * 2] = self.chromaB[i * self.chromaBLineSize + j];
            // v
            uvData[i * self.width + j * 2 + 1] = self.chromaR[i * self.chromaRLineSize + j];
        }
    }
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    return pixelBuffer;
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
