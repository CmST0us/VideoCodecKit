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


/**
 创建parseData内存

 @param size 大小，注意实际创建的时候会在头多分配4字节，以便于添加修改start code。即parseData指向实际分配后4字节地址。
 */
- (void)createParseDataWithSize:(NSUInteger)size;
/**
 使用多分配的空间

 @param length 使用多少字节（小于等于4）
 */
- (void)useExternParseDataLength:(NSUInteger)length;
@end
