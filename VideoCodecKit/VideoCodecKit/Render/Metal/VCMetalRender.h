//
//  VCMetalRender.h
//  VideoCodecKit
//
//  Created by CmST0us on 2018/10/31.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MetalKit/MetalKit.h>
#import <Metal/MTLDevice.h>
#import "VCBaseRenderProtocol.h"

#if (TARGET_IPHONE_SIMULATOR)
#else
@interface VCMetalRender : NSObject<VCBaseRenderProtocol>
@property (nonatomic, assign) vector_uint2 viewportSize;
@property (nonatomic, strong) MTKView *mtkView;
@end
#endif
