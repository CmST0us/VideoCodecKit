//
//  VCRTMPSession+ProtocolControlMessageHandler.m
//  VideoCodecKit
//
//  Created by CmST0us on 2020/2/6.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import "VCRTMPSession+ProtocolControlMessageHandler.h"
#import "VCRTMPSession_Private.h"
#import "VCRTMPCommandMessageCommand.h"
#import "VCRTMPChunk.h"
#import "VCRTMPMessage.h"

@implementation VCRTMPSession (ProtocolControlMessageHandler)
- (void)handleMessageTypeWindowAcknowledgement:(VCRTMPChunk *)chunk {
    NSInteger s = [chunk windowAcknowledgementSizeValue];
    NSLog(@"Window Acknowledgement Size: %ld", (long)s);
}

- (void)handleSetPeerBandwidthValue:(VCRTMPChunk *)chunk {
    NSInteger s = [chunk setPeerBandwidthValue];
    NSLog(@"Set Peer Bandwidth: %ld", (long)s);
}

- (void)handleSetChunkSize:(VCRTMPChunk *)chunk {
    NSInteger s = [chunk setChunkSizeValue];
    NSLog(@"Set Chunk Size: %ld", (long)s);
}

- (void)handleAMF0Command:(VCRTMPChunk *)chunk {
    NSLog(@"Command: %@", [VCRTMPCommandMessageCommandFactory commandWithType:chunk.commandTypeValue data:chunk.chunkData]);
}
@end
