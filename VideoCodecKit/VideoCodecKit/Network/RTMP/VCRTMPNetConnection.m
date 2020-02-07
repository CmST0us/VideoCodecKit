//
//  VCRTMPNetConnection.m
//  VideoCodecKit
//
//  Created by CmST0us on 2020/2/5.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import "VCRTMPNetConnection.h"
#import "VCRTMPNetConnection_Private.h"
#import "VCRTMPSession.h"
#import "VCRTMPSession_Private.h"
#import "VCRTMPSession+CommandMessageHandler.h"

#import "VCRTMPChunkChannel.h"
#import "VCRTMPCommandMessageCommand.h"

NSErrorDomain const VCRTMPNetConnectionErrorDomain = @"VCRTMPNetConnectionErrorDomain";

@implementation VCRTMPNetConnection

+ (instancetype)netConnectionForSession:(VCRTMPSession *)session {
    VCRTMPNetConnection *connection = [[VCRTMPNetConnection alloc] init];
    connection.session = session;
    return connection;
}

- (void)connecWithParam:(NSDictionary *)param completion:(VCRTMPCommandMessageResponseBlock)block {
    self.resultBlock = block;
    
    VCRTMPNetConnectionCommandConnect *command = [[VCRTMPNetConnectionCommandConnect alloc] init];
    command.commandName = @"connect";
    command.transactionID = @([self.session nextTransactionID]);
    command.commandObject = param;
    VCRTMPChunk *chunk = [VCRTMPChunk makeNetConnectionCommand:command];
    [self.session registerTransactionID:command.transactionID.unsignedIntegerValue
                               observer:self
                                handler:@selector(handleConnectionResult:)];
    [self.session.channel writeFrame:chunk];
}

#pragma mark - Handle Message
- (void)handleConnectionResult:(VCRTMPCommandMessageResponse *)result {
    BOOL success = NO;
    if ([result.response isEqualToString:VCRTMPCommandMessageResponseSuccess]) {
        success = YES;
        result = [[VCRTMPNetConnectionCommandConnectResult alloc] initWithData:result.chunkData];
        [result deserialize];
    }
    if (self.resultBlock) {
        self.resultBlock(result, success);
    }
}

@end
