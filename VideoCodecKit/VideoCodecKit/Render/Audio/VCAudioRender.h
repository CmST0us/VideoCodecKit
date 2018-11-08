//
//  VCAudioRender.h
//  VideoCodecKit
//
//  Created by CmST0us on 2018/11/8.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCBaseRenderProtocol.h"

@interface VCAudioRender : NSObject<VCBaseRenderProtocol>
@property (nonatomic, readonly) AudioStreamBasicDescription basicDescription;

- (instancetype)initWithAudioStreamBasicDescription:(AudioStreamBasicDescription)description;

- (void)stop;
- (void)play;
@end

