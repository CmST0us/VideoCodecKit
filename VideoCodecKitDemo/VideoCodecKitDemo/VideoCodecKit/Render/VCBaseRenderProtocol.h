//
//  VCBaseRenderProtocol.h
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/21.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "VCImageTypeProtocol.h"

@protocol VCBaseRenderProtocol<NSObject>
@required
- (void)attachToLayer:(CALayer *)layer;

- (void)renderImage:(id<VCImageTypeProtocol>)image;
- (NSArray<NSString *> *)supportRenderImageClassName;
@end
