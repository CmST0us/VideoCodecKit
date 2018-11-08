//
//  VCAudioFrame.h
//  VideoCodecKit
//
//  Created by CmST0us on 2018/11/6.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "VCBaseFrame.h"
/**
 AAC 帧和 H264帧不同点在于，AAC更接近于流，而H264更接近于包。
 故此类在设计时参考AudioBufferList，作为一个链表
 */
@interface VCAudioFrame : VCBaseFrame
@property (nonatomic, assign) AudioStreamPacketDescription packetDescription;
@end
