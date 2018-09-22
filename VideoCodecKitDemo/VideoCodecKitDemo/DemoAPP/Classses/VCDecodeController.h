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
#import "VCH264FFmpegDecoder.h"
#import "VCPreviewer.h"

@interface VCDecodeController : NSObject<VCPreviewerDelegate>

@property (nonatomic, copy) NSString *parseFilePath;
@property (nonatomic, strong) VCPreviewer *previewer;

- (void)startParse;
- (void)stopParse;

@end
