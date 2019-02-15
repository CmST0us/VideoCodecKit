//
//  VCDemoRTMPFormatTestViewController.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2019/2/16.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "VCDemoRTMPFormatTestViewController.h"
#import <VideoCodecKit/VideoCodecKit.h>

@implementation VCDemoRTMPFormatTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    VCRTMPMessage *message = [[VCRTMPMessage alloc] init];
    message.timestamp = 1;
    message.messageStreamID = 2;
    message.messageTypeID = VCRTMPMessageTypeVideo;
    message.messageLength = 3;
    
    VCRTMPChunk *chunk = [[VCRTMPChunk alloc] initWithType:VCRTMPChunkMessageHeaderType3 chunkStreamID:VCRTMPChunkStreamIDVideo message:message];
    
    NSData *chunkData = [chunk makeChunkHeader];
    chunkData;
}
@end
