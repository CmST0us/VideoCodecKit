//
//  VCVTH264Decoder.h
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/22.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import "VCBaseDecoder.h"

@class VCH264SPSFrame;
@class VCH264PPSFrame;
@interface VCVTH264Decoder : VCBaseDecoder
@property (nonatomic, readonly) VCH264SPSFrame *currentSPSFrame;
@property (nonatomic, readonly) VCH264PPSFrame *currentPPSFrame;
@end
