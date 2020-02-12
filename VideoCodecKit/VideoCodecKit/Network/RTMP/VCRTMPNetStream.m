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
#import "VCRTMPSession+CommandMessageHandler.h"
#import "VCRTMPChunk.h"
#import "VCRTMPMessage.h"

@implementation VCRTMPNetStream

- (void)dealloc {
    [self.netConnection.session removeMessageStreamIDTask:self.streamID];
}

+ (instancetype)netStreamWithName:(NSString *)streamName
                         streamID:(uint32_t)streamID
                 forNetConnection:(VCRTMPNetConnection *)netConnection {
    VCRTMPNetStream *netStream = [[VCRTMPNetStream alloc] init];
    netStream.streamName = streamName;
    netStream.streamID = streamID;
    netStream.netConnection = netConnection;
    [netConnection.session registerMessageStreamID:streamID
                                          observer:netStream
                                           handler:@selector(handleNetStreamMessage:)];
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

#pragma mark - Set Meta Data
- (void)setMetaData:(NSDictionary<NSString *,VCActionScriptType *> *)param {
    VCRTMPNetStreamCommandSetDataFrame *command = [VCRTMPNetStreamCommandSetDataFrame command];
    command.subCommandName = @"onMetaData";
    command.param = param;
    
    VCRTMPChunk *chunk = [self makeNetStreamChunkWithCommand:command];
    [self.netConnection.session.channel writeFrame:chunk];
}

#pragma mark - Net Stream Message Handle
+ (NSDictionary<NSString *, NSString *> *)commandMessageHandlerMap {
    static NSDictionary *map = nil;
    if (map != nil) {
        return map;
    }
    map = @{
        @"onStatus": NSStringFromSelector(@selector(handleOnStatusMessage:)),
    };
    return map;
}

- (void)handleNetStreamMessage:(VCRTMPChunk *)chunk {
    VCRTMPCommandMessageResponse *response = [[VCRTMPCommandMessageResponse alloc] initWithData:chunk.chunkData];
    [response deserialize];
    NSString *selString = [[[self class] commandMessageHandlerMap] objectForKey:response.response];
    SEL selector = NSSelectorFromString(selString);
    if (selector) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:selector withObject:response];
#pragma clang diagnostic pop
    }
}

- (void)handleOnStatusMessage:(VCRTMPCommandMessageResponse *)response {
    VCRTMPNetStreamCommandOnStatus *onStatus = [[VCRTMPNetStreamCommandOnStatus alloc] initWithData:response.chunkData];
    BOOL isSuccess = NO;
    if (onStatus.information) {
        NSString *levelStr = [onStatus.information objectForKey:@"level"].value;
        if (levelStr &&
            [levelStr isEqualToString:VCRTMPCommandMessageResponseLevelStatus]) {
            isSuccess = YES;
        }
    }
    if (self.responseBlock) {
        self.responseBlock(onStatus, isSuccess);
        self.responseBlock = nil;
    }
}

@end
