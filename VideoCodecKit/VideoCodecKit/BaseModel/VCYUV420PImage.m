//
//  VCYUV420PImage.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/20.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import "VCYUV420PImage.h"

@interface VCYUV420PImage ()

@end

@implementation VCYUV420PImage

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
    if (_pixelBuffer != NULL) return _pixelBuffer;
    
    if (self.luma == nil || self.chromaB == nil || self.chromaR == nil) return nil;
    CVPixelBufferRef pixelBuffer = NULL;
    
    NSDictionary *attr = @{
                           (id)kCVPixelBufferOpenGLCompatibilityKey: @(YES),
                           (id)kCVPixelBufferBytesPerRowAlignmentKey: @(self.lumaLineSize),
                           (id)kCVPixelBufferMetalCompatibilityKey: @(YES),
#if !(TARGET_IPHONE_SIMULATOR)
                           (id)kCVPixelBufferIOSurfaceOpenGLESFBOCompatibilityKey: @(YES),
                           (id)kCVPixelBufferIOSurfaceCoreAnimationCompatibilityKey: @(YES),
                           (id)kCVPixelBufferIOSurfaceOpenGLESTextureCompatibilityKey: @(YES),
#endif
                           };
    
    CVPixelBufferCreate(kCFAllocatorDefault,
                        self.width,
                        self.height,
                        kCVPixelFormatType_420YpCbCr8BiPlanarFullRange, (__bridge CFDictionaryRef)attr, &pixelBuffer);
    
    if (_pixelBuffer != NULL) {
        CVPixelBufferRelease(_pixelBuffer);
        _pixelBuffer = NULL;
    }
    
    _pixelBuffer = CVPixelBufferRetain(pixelBuffer);
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    uint8_t *yData = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    uint8_t *uvData = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
    
    memcpy(yData, self.luma, self.lumaLineSize * self.height);
    
    // UV 交叉储存！！！！
    // 注意对齐！！！
    for (int i = 0; i < self.height / 2; ++i) {
        for (int j = 0; j < self.lumaLineSize; j = j + 1) {
            // u
            uvData[i * self.lumaLineSize + j * 2] = self.chromaB[i * self.chromaBLineSize + j];
            // v
            uvData[i * self.lumaLineSize + j * 2 + 1] = self.chromaR[i * self.chromaRLineSize + j];
        }
    }
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    CVPixelBufferRelease(pixelBuffer);
    return pixelBuffer;
}

- (NSString *)classStringForImageType {
    return NSStringFromClass([self class]);
}
@end
