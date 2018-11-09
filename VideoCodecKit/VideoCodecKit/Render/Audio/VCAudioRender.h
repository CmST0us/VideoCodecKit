//
//  VCAudioRender.h
//  VideoCodecKit
//
//  Created by CmST0us on 2018/11/8.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCBaseRenderProtocol.h"

/**
 render 一个 VCAudioFrameParser 对象。
 */
@interface VCAudioRender : NSObject<VCBaseRenderProtocol>
@property (nonatomic, readonly) AudioStreamBasicDescription basicDescription;

- (void)stop;
- (void)play;
@end

