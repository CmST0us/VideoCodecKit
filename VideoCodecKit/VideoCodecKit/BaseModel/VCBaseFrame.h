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
@property (nonatomic, strong) NSMutableDictionary *userInfo;
@end
