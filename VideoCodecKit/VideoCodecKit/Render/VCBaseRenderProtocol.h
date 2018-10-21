//
//  VCBaseRenderProtocol.h
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/21.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "VCBaseImage.h"

@protocol VCBaseRenderProtocol<NSObject>
@required
- (void)attachToLayer:(CALayer *)layer;

- (void)renderImage:(VCBaseImage *)image;
- (NSArray<NSString *> *)supportRenderImageClassName;
@end
