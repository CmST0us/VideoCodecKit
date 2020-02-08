//
//  VCRTMPNetStream.m
//  VideoCodecKit
//
//  Created by CmST0us on 2020/2/8.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import "VCRTMPNetStream.h"
#import "VCRTMPNetStream_Private.h"
#import "VCRTMPNetConnection_Private.h"
#import "VCRTMPSession_Private.h"
#import "VCRTMPChunk.h"
#import "VCRTMPMessage.h"

@implementation VCRTMPNetStream

+ (instancetype)netStreamWithName:(NSString *)streamName
                         streamID:(uint32_t)streamID
                 forNetConnection:(VCRTMPNetConnection *)netConnection {
    VCRTMPNetStream *netStream = [[VCRTMPNetStream alloc] init];
    netStream.streamName = streamName;
    netStream.streamID = streamID;
    netStream.netConnection = netConnection;
    return netStream;
}

- (VCRTMPChunk *)makeNetStreamChunkWithCommand:(VCRTMPCommandMessageCommand *)command {
    VCRTMPChunk *chunk = [VCRTMPChunk makeNetStreamCommand:command];
    chunk.message.messageStreamID = self.streamID;
    return chunk;
}

#pragma mark - Publish
- (void)publishWithCompletion:(VCRTMPCommandMessageResponseBlock)block {
    self.responseBlock = block;
    
    VCRTMPNetStreamCommandPublish *command = [VCRTMPNetStreamCommandPublish command];
    command.transactionID = @([self.netConnection.session nextTransactionID]);
    command.publishingName = self.streamName;
    command.publishingType = VCRTMPNetStreamCommandPublishTypeLive;
    
    VCRTMPChunk *chunk = [self makeNetStreamChunkWithCommand:command];
    [self.netConnection.session.channel writeFrame:chunk];
}

@end
