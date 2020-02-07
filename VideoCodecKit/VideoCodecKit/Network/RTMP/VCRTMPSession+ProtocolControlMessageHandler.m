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
    NSLog(@"[RTMP][CHANNEL] Window Acknowledgement Size: %ld", (long)s);
    self.channel.acknowlegmentWindowSize = s;
}

- (void)handleSetPeerBandwidthValue:(VCRTMPChunk *)chunk {
    NSInteger s = [chunk setPeerBandwidthValue];
    NSLog(@"[RTMP][CHANNEL] Set Peer Bandwidth: %ld", (long)s);
}

- (void)handleSetChunkSize:(VCRTMPChunk *)chunk {
    NSInteger s = [chunk setChunkSizeValue];
    NSLog(@"[RTMP][CHANNEL] Set Chunk Size: %ld", (long)s);
    self.channel.remoteChunkSize = s;
}

- (void)handleAMF0Command:(VCRTMPChunk *)chunk {
    NSLog(@"[RTMP][CHANNEL] Command: %@", [VCRTMPCommandMessageCommandFactory commandWithType:chunk.commandTypeValue data:chunk.chunkData]);
}

- (void)handleAcknowledgement:(VCRTMPChunk *)chunk {
    NSInteger s = [chunk acknowledgementValue];
    NSLog(@"[RTMP][CHANNEL] Ack: %ld", (long)s);
    [self.channel resetSendByteCount];
}

@end
