//
//  VCRTMPNetConnection.m
//  VideoCodecKit
//
//  Created by CmST0us on 2020/2/5.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import "VCRTMPNetConnection.h"
#import "VCRTMPCommandMessageCommand.h"
#import "VCRTMPChunk.h"
#import "VCRTMPMessage.h"
#import "VCAMF0Serialization.h"
#import "VCByteArray.h"
#import "VCRTMPChunkStreamSpliter.h"

NSErrorDomain const VCRTMPNetConnectionErrorDomain = @"VCRTMPNetConnectionErrorDomain";

@interface VCRTMPNetConnection () <VCRTMPChunkStreamSpliterDelegate>
@property (nonatomic, strong) VCRTMPChunkStreamSpliter *spliter;
@end

@implementation VCRTMPNetConnection

+ (instancetype)netConnectionForSocket:(VCTCPSocket *)socket {
    VCRTMPNetConnection *connection = [[VCRTMPNetConnection alloc] init];
    connection.spliter = [VCRTMPChunkStreamSpliter spliterForSocket:socket];
    connection.spliter.delegate = connection;
    return connection;
}

- (void)connecWithParam:(NSDictionary *)param {
    VCRTMPChunk *chunk = [self makeConnectChunkWithParam:param];
    [self.spliter writeFrame:chunk];
}

#pragma mark - RTMP Message
- (VCRTMPChunk *)makeConnectChunkWithParam:(NSDictionary *)parm {
    VCRTMPNetConnectionCommandConnect *command = [[VCRTMPNetConnectionCommandConnect alloc] init];
    command.commandName = @"connect";
    command.transactionID = @(1);
    command.commandObject = parm;
    
    VCRTMPChunk *chunk = [VCRTMPChunk makeNetConnectionCommand:command];
    return chunk;
}

#pragma mark - Net Connection
- (void)spliter:(VCRTMPChunkStreamSpliter *)spliter didReceiveFrame:(VCRTMPChunk *)chunk {
    NSLog(@"收到%@", chunk);
    if (chunk.message.messageTypeID == VCRTMPMessageTypeWindowAcknowledgement) {
        NSInteger s = [chunk windowAcknowledgementSizeValue];
        NSLog(@"Window Acknowledgement Size: %d", s);
    } else if (chunk.message.messageTypeID == VCRTMPMessageTypeSetPeerBandwidth) {
        NSInteger s = [chunk setPeerBandwidthValue];
        NSLog(@"Set Peer Bandwidth: %d", s);
    } else if (chunk.message.messageTypeID == VCRTMPMessageTypeSetChunkSize) {
        NSInteger s = [chunk setChunkSizeValue];
        NSLog(@"Set Chunk Size: %d", s);
    } else if (chunk.message.messageTypeID == VCRTMPMessageTypeAMF0Command) {
        NSLog(@"Command: %@", [VCRTMPCommandMessageCommandFactory commandWithType:chunk.commandTypeValue data:chunk.chunkData]);
    }
}

- (void)spliterConnectionDidEnd {
    NSLog(@"end");
}

- (void)spliter:(VCRTMPChunkStreamSpliter *)spliter connectionHasError:(NSError *)error {
    NSLog(@"error: %@", error);
}

@end
