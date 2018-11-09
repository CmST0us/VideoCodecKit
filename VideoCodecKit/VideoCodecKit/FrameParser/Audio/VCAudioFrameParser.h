//
//  VCAudioFrameParser.h
//  VideoCodecKit
//
//  Created by CmST0us on 2018/11/8.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "VCBaseFrameParser.h"

@interface VCAudioFrameParser : VCBaseFrameParser
@property (nonatomic, readonly) AudioFileTypeID audioType;

- (instancetype)initWithAudioType:(AudioFileTypeID)audioType;
- (NSInteger)parseData:(void *)buffer length:(NSInteger)length;
@end
