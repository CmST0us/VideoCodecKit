//
//  VCBaseRenderProtocol.h
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/21.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCBaseImage.h"

@class UIView;
@protocol VCBaseRenderProtocol<NSObject>
@required
- (UIView *)renderView;
- (void)attachToView:(UIView *)view;
- (void)renderImage:(VCBaseImage *)image;
- (NSArray<NSString *> *)supportRenderImageClassName;
@end
