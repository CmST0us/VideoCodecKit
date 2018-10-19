//
//  VCBaseFrame.h
//  VideoCodecKit
//
//  Created by CmST0us on 2018/10/19.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString const *kVCBaseFrameUserInfoFFmpegContextKey;

@interface VCBaseFrame: NSObject
@property (nonatomic, strong) NSDictionary *userInfo;
@end