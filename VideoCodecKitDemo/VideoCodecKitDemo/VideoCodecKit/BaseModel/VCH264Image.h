//
//  VCH264Image.h
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/16.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>
#import "VCImageTypeProtocol.h"

typedef NS_ENUM(NSUInteger, VCH264SliceType) {
    VCH264SliceTypeNone = 0, ///< Undefined
    VCH264SliceTypeI,     ///< Intra
    VCH264SliceTypeP,     ///< Predicted
    VCH264SliceTypeB,     ///< Bi-dir predicted
    VCH264SliceTypeS,     ///< S(GMC)-VOP MPEG-4
    VCH264SliceTypeSI,    ///< Switching Intra
    VCH264SliceTypeSP,    ///< Switching Predicted
    VCH264SliceTypeBI,    ///< BI type
};

@interface VCH264Image : NSObject<VCImageTypeProtocol>

@property (nonatomic, assign) VCH264SliceType sliceType;

@property (nonatomic, assign) NSUInteger width;
@property (nonatomic, assign) NSUInteger height;

@property (nonatomic, assign) uint8_t *luma; //Y
@property (nonatomic, assign) NSUInteger lumaSize;
@property (nonatomic, assign) NSUInteger lumaLineSize;

@property (nonatomic, assign) uint8_t *chromaB; // U
@property (nonatomic, assign) NSUInteger chromaBSize;
@property (nonatomic, assign) NSUInteger chromaBLineSize;

@property (nonatomic, assign) uint8_t *chromaR; // V
@property (nonatomic, assign) NSUInteger chromaRSize;
@property (nonatomic, assign) NSUInteger chromaRLineSize;

- (instancetype)initWithWidth:(NSUInteger)width
                       height:(NSUInteger)height;

- (void)createLumaDataWithSize:(NSUInteger)size
                   AndLineSize:(NSUInteger)lineSize;

- (void)createChromaBDataWithSize:(NSUInteger)size
                      AndLineSize:(NSUInteger)lineSize;

- (void)createChromaRDataWithSize:(NSUInteger)size
                      AndLineSize:(NSUInteger)lineSize;

- (NSData *)yuv420pPlaneData;
- (NSData *)nv12PlaneData;

- (CVPixelBufferRef)pixelBuffer;

@end
