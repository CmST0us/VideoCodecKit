//
//  VCH264FrameParser.h
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/9.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import "VCBaseFrameParser.h"

@class VCH264Frame;
@interface VCH264FrameParser : VCBaseFrameParser

@property (nonatomic, strong) VCH264Frame *currentParseFrame;

@end
