//
//  VCH264FrameParser.h
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/9.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import "VCBaseFrameParser.h"

@interface VCH264FrameParser : VCBaseFrameParser

@property (nonatomic, readonly) VCH264Frame *currentParseFrame;

@end
