//
//  VCBaseFrame.h
//  VideoCodecKit
//
//  Created by CmST0us on 2018/10/19.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCMarco.h"

DECLARE_CONST_STRING(kVCBaseFrameUserInfoFFmpegAVCodecContextKey);

@interface VCBaseFrame: NSObject
@property (nonatomic, assign) uint8_t *parseData;
@property (nonatomic, assign) NSUInteger parseSize;
@property (nonatomic, strong) NSMutableDictionary *userInfo;

@property (nonatomic, assign) NSUInteger width;
@property (nonatomic, assign) NSUInteger height;

- (instancetype)initWithWidth:(NSUInteger)width
                       height:(NSUInteger)height;

- (void)createParseDataWithSize:(NSUInteger)size;
@end
