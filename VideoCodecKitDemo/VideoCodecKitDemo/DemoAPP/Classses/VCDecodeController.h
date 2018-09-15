//
//  VCDecodeController.h
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/9.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCH264FFmpegFrameParser.h"
#import "VCH264Frame.h"

@interface VCDecodeController : NSObject<VCFrameParserDelegate>

@property (nonatomic, strong) VCH264FFmpegFrameParser *parser;

@property (nonatomic, copy) NSString *parseFilePath;

- (void)startParse;
- (void)stopParse;

@end
