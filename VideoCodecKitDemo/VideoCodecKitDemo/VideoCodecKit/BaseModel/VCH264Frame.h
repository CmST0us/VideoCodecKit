//
//  VCH264Frame.h
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/9.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VCFrameTypeProtocol.h"
#import "VCYUV422Image.h"

typedef NS_ENUM(NSUInteger, VCH264FrameType) {
    VCH264FrameTypeUnknown,
    VCH264FrameTypeSPS,
    VCH264FrameTypePPS,
    VCH264FrameTypeIDR,
};

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

@interface VCH264Frame : NSObject<VCFrameTypeProtocol>

@property (nonatomic, assign) VCH264FrameType frameType;
@property (nonatomic, assign) VCH264SliceType sliceType;
@property (nonatomic, assign) NSUInteger frameIndex;

@property (nonatomic, assign) NSUInteger width;
@property (nonatomic, assign) NSUInteger height;

@property (nonatomic, assign) uint8_t *parseData;
@property (nonatomic, assign) NSUInteger parseSize;

@property (nonatomic, strong) VCYUV422Image *image;

- (instancetype)initWithWidth:(NSUInteger)width
                       height:(NSUInteger)height;
    
- (void)createParseDaraWithSize:(NSUInteger)size;
@end
