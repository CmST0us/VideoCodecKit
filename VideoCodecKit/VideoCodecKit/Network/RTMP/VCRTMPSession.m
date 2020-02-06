//
//  VCRTMPSession.m
//  VideoCodecKit
//
//  Created by CmST0us on 2019/2/3.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "VCRTMPSession.h"
#import "VCRTMPSession_Private.h"
#import "VCRTMPSession+ProtocolControlMessageHandler.h"
#import "VCRTMPChunkStreamSpliter.h"
#import "VCTCPSocket.h"
#import "VCRTMPMessage.h"
#import "VCRTMPCommandMessageCommand.h"
#import "VCRTMPNetConnection.h"

NSErrorDomain const VCRTMPSessionErrorDomain = @"VCRTMPSessionErrorDomain";

@implementation VCRTMPSession

+ (instancetype)sessionForSocket:(VCTCPSocket *)socket {
    VCRTMPSession *session = [[VCRTMPSession alloc] init];
    VCRTMPChunkStreamSpliter *spliter = [VCRTMPChunkStreamSpliter spliterForSocket:socket];
    session.spliter = spliter;
    session.spliter.delegate = session;
    return session;
}

#pragma mark - Net Connection
- (VCRTMPNetConnection *)makeNetConnection {
    VCRTMPNetConnection *netConnection = [VCRTMPNetConnection netConnectionForSession:self];
    return netConnection;
}

#pragma mark - Protocol Control Message
- (void)setChunkSize:(uint32_t)size {
    VCRTMPChunk *chunk = [VCRTMPChunk makeSetChunkSize:size];
    [self.spliter writeFrame:chunk];
}

- (void)abortMessage:(uint32_t)streamID {
    VCRTMPChunk *chunk = [VCRTMPChunk makeAbortMessage:streamID];
    [self.spliter writeFrame:chunk];
}

- (void)setPeerBandwidth:(uint32_t)bandwidth limitType:(VCRTMPChunkSetPeerBandwidthLimitType)limitType {
    VCRTMPChunk *chunk = [VCRTMPChunk makeSetPeerBandwidth:bandwidth limitType:limitType];
    [self.spliter writeFrame:chunk];
}

#pragma mark - Handle Protocol Control Message
+ (NSDictionary *)protocolControlMessageHandlerMap {
    static NSDictionary *map = nil;
    if (map != nil) {
        return map;
    }
    map = @{
        @(VCRTMPMessageTypeWindowAcknowledgement): @"handleMessageTypeWindowAcknowledgement:",
        @(VCRTMPMessageTypeSetPeerBandwidth): @"handleSetPeerBandwidthValue:",
        @(VCRTMPMessageTypeSetChunkSize): @"handleSetChunkSize:",
        @(VCRTMPMessageTypeAMF0Command): @"handleAMF0Command:"
    };
    return map;
}

#pragma mark - Chunk Packet
- (void)spliter:(VCRTMPChunkStreamSpliter *)spliter didReceiveFrame:(VCRTMPChunk *)chunk {
    NSLog(@"收到%@", chunk);
    NSString *handler = [[self class] protocolControlMessageHandlerMap][@(chunk.message.messageTypeID)];
    if (handler) {
        SEL selector = NSSelectorFromString(handler);
        if (selector &&
            [self respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self performSelector:selector withObject:chunk];
#pragma clang diagnostic pop
        }
    }
}

- (void)spliterConnectionDidEnd {
    NSLog(@"end");
}

- (void)spliter:(VCRTMPChunkStreamSpliter *)spliter connectionHasError:(NSError *)error {
    NSLog(@"error: %@", error);
}

@end
