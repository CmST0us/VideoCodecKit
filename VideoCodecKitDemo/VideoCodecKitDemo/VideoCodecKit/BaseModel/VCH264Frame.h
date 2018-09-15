//
//  VCH264Frame.h
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/9.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCFrameTypeProtocol.h"

@interface VCH264Frame : NSObject<VCFrameTypeProtocol>

@property (nonatomic, assign) BOOL isSPS;
@property (nonatomic, assign) BOOL isPPS;
@property (nonatomic, assign) BOOL isIDR;

@property (nonatomic, assign) NSUInteger frameIndex;

@property (nonatomic, assign) NSUInteger width;
@property (nonatomic, assign) NSUInteger height;

@property (nonatomic, assign) uint8_t *parseData;
@property (nonatomic, assign) NSUInteger parseSize;

@property (nonatomic, assign) uint8_t *frameData;
@property (nonatomic, assign) NSUInteger frameSize;

@end
