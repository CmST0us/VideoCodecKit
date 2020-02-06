//
//  VCDemoAMFTestViewController.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2019/2/13.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <VideoCodecKit/VideoCodecKit.h>
#import "VCDemoAMFTestViewController.h"

@implementation VCDemoAMFTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDictionary *parm = @{
        @"app": @"VideoCodecKit::RTMP".asString,
        @"tcUrl": @"rtmp://127.0.0.1/stream".asString,
        @"flashVer": @"FMLE/3.0 (compatible; FMSc/1.0)".asString,
        @"swfUrl": NSNull.asNull,
        @"fpad": @(NO).asBool,
        @"audioCodecs": @(0x0400).asNumber,
        @"videoCodecs": @(0x0080).asNumber,
        @"objectEncodeing": @(0).asNumber,
    };
    VCByteArray *arr = [[VCByteArray alloc] init];
    VCActionScriptObject *commandObj = [VCActionScriptObject asTypeWithDictionary:parm];
    
    [@"connect".asString serializeWithTypeMarkToArrayByte:arr];
    [@(1).asNumber serializeWithTypeMarkToArrayByte:arr];
    [commandObj serializeWithTypeMarkToArrayByte:arr];

    NSData *data = arr.data;
    NSLog(@"\nChunkData: %@",data.debugDescription);
    
    VCRTMPMessage *message = [[VCRTMPMessage alloc] init];
    message.messageTypeID = VCRTMPMessageTypeAMF0Command;
    VCRTMPChunk *chunk = [[VCRTMPChunk alloc] initWithType:VCRTMPChunkMessageHeaderType0
                                             chunkStreamID:VCRTMPChunkStreamIDCommand
                                                   message:message];
    chunk.chunkData = data;
    NSData *c = [chunk makeChunk];
    NSLog(@"\nChunk: %@", c.debugDescription);
}

@end
