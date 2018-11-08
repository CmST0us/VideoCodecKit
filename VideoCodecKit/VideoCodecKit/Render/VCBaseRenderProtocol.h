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
- (UIView *)renderView;
- (void)attachToView:(UIView *)view;
- (void)render:(id)image;
@required
- (NSArray<NSString *> *)supportRenderClassName;
@end
