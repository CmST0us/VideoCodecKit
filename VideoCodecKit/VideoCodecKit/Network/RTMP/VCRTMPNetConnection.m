//
//  VCRTMPNetConnection.m
//  VideoCodecKit
//
//  Created by CmST0us on 2020/2/5.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import "VCRTMPNetConnection.h"
#import "VCRTMPSession.h"
#import "VCRTMPSession_Private.h"
#import "VCRTMPChunkStreamSpliter.h"
#import "VCRTMPCommandMessageCommand.h"

NSErrorDomain const VCRTMPNetConnectionErrorDomain = @"VCRTMPNetConnectionErrorDomain";

@interface VCRTMPNetConnection ()
@property (nonatomic, weak) VCRTMPSession *session;
@end

@implementation VCRTMPNetConnection

+ (instancetype)netConnectionForSession:(VCRTMPSession *)session {
    VCRTMPNetConnection *connection = [[VCRTMPNetConnection alloc] init];
    connection.session = session;
    return connection;
}

- (void)connecWithParam:(NSDictionary *)param {
    VCRTMPChunk *chunk = [self makeConnectChunkWithParam:param];
    [self.session.spliter writeFrame:chunk];
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

@end
