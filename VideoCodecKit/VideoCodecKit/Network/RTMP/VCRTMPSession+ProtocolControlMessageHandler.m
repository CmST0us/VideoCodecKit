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
- (void)handleWindowAcknowledgementSize:(VCRTMPChunk *)chunk {
    NSInteger s = [chunk windowAcknowledgementSizeValue];
    NSLog(@"[RTMP][CHANNEL] Window Acknowledgement Size: %ld", (long)s);
    self.channel.acknowlegmentWindowSize = s;
}

- (void)handleSetPeerBandwidthValue:(VCRTMPChunk *)chunk {
    uint32_t s = (uint32_t)[chunk setPeerBandwidthValue];
    VCRTMPChunkSetPeerBandwidthLimitType limitType = [chunk limitTypeValue];
    NSLog(@"[RTMP][CHANNEL] Set Peer Bandwidth: %ld", (long)s);
    
    __weak typeof(self) weakSelf = self;
    void (^setBandwidthBlock)(uint32_t size) = ^(uint32_t size) {
        if (weakSelf.channel.acknowlegmentWindowSize != size) {
            [weakSelf respondWindowAcknowledgmentWithSize:size];
        }
        weakSelf.channel.acknowlegmentWindowSize = size;
        [weakSelf.channel useCurrntAcknowlegmentWindowSizeAsBandwidth];
    };
    
    if (limitType == VCRTMPChunkSetPeerBandwidthLimitTypeHard) {
        setBandwidthBlock(s);
    } else if (limitType == VCRTMPChunkSetPeerBandwidthLimitTypeSoft ||
               limitType == VCRTMPChunkSetPeerBandwidthLimitTypeDynamic) {
        if (self.channel.bandwidth == 0) {
            setBandwidthBlock(s);
        } else {
            uint32_t minBandwidth = MIN((uint32_t)self.channel.bandwidth, s);
            setBandwidthBlock(minBandwidth);
        }
    }
}

- (void)handleSetChunkSize:(VCRTMPChunk *)chunk {
    NSInteger s = [chunk setChunkSizeValue];
    NSLog(@"[RTMP][CHANNEL] Set Chunk Size: %ld", (long)s);
    self.channel.remoteChunkSize = s;
}

- (void)handleAcknowledgement:(VCRTMPChunk *)chunk {
    NSInteger s = [chunk acknowledgementValue];
    NSLog(@"[RTMP][CHANNEL] Ack: %ld", (long)s);
    [self.channel resetSendByteCount];
}

@end
