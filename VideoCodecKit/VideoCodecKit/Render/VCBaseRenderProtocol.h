//
//  VCBaseRenderProtocol.h
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/21.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCBaseImage.h"
#import "VCAudioFrame.h"

@class UIView;
@protocol VCBaseRenderProtocol<NSObject>
@optional
- (UIView *)renderView;
- (void)attachToView:(UIView *)view;
@required
- (void)render:(id)object;
- (NSArray<NSString *> *)supportRenderClassName;
@end
