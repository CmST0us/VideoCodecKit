//
//  VCRTMPNetConnection.m
//  VideoCodecKit
//
//  Created by CmST0us on 2020/2/5.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import "VCRTMPNetConnection.h"
#import "VCRTMPChunk.h"
#import "VCRTMPMessage.h"
#import "VCAMF0Serialization.h"
#import "VCByteArray.h"
#import "VCSafeBuffer.h"

NSErrorDomain const VCRTMPNetConnectionErrorDomain = @"VCRTMPNetConnectionErrorDomain";

@interface VCRTMPNetConnection () <VCTCPSocketDelegate>
@property (nonatomic, strong) VCTCPSocket *socket;

@property (nonatomic, strong) VCSafeBuffer *buffer;
@end

@implementation VCRTMPNetConnection

- (VCSafeBuffer *)buffer {
    if (_buffer == nil) {
        _buffer = [[VCSafeBuffer alloc] init];
    }
    return _buffer;
}

+ (instancetype)netConnectionForSocket:(VCTCPSocket *)socket {
    VCRTMPNetConnection *connection = [[VCRTMPNetConnection alloc] init];
    socket.delegate = connection;
    connection.socket = socket;
    return connection;
}

- (void)connecWithParam:(NSDictionary *)param {
    VCRTMPChunk *chunk = [self makeConnectChunkWithParam:param];
    [self.socket writeData:[chunk makeChunk]];
}

#pragma mark - RTMP Message
- (VCRTMPChunk *)makeConnectChunkWithParam:(NSDictionary *)parm {
    VCByteArray *arr = [[VCByteArray alloc] init];
    VCActionScriptObject *commandObj = [VCActionScriptObject asTypeWithDictionary:parm];
    VCActionScriptObject *obj = [[VCActionScriptObject alloc] init];
    obj.value = @{
        @"CommandName": @"connect".asString,
        @"TransactionID": @(1).asNumber,
        @"CommandObject": commandObj,
    }.mutableCopy;
    
    [obj serializeToArrayByte:arr];

    NSData *data = arr.data;
    VCRTMPMessage *message = [[VCRTMPMessage alloc] init];
    message.messageTypeID = VCRTMPMessageTypeAMF0Command;
    VCRTMPChunk *chunk = [[VCRTMPChunk alloc] initWithType:VCRTMPChunkMessageHeaderType0
                                             chunkStreamID:VCRTMPChunkStreamIDCommand
                                                   message:message];
    chunk.chunkData = data;
    return chunk;
}

#pragma mark - Net Connection
- (void)handleNetConnectionErrorWithCode:(VCRTMPNetConnectionErrorCode)code {
    [self.socket close];
}

- (void)handleNetConnectionPacket {
    
}

#pragma mark - TCP Delegate
- (void)tcpSocketEndcountered:(VCTCPSocket *)socket {
    [self handleNetConnectionErrorWithCode:VCRTMPNetConnectionErrorCodeConnectReset];
}

- (void)tcpSocketErrorOccurred:(VCTCPSocket *)socket {
    [self handleNetConnectionErrorWithCode:VCRTMPNetConnectionErrorCodeConnectError];
}

- (void)tcpSocketConnectTimeout:(VCTCPSocket *)socket {
    /// Pass
}

- (void)tcpSocketHasByteAvailable:(VCTCPSocket *)socket {
    while ([self.socket byteAvaliable]) {
        NSData *recvData = [self.socket readData];
        if (recvData.length == 0) {
            [self tcpSocketEndcountered:socket];
            return;
        }
        
        [self.buffer push:[[VCSafeBufferNode alloc] initWithData:recvData]];
    }
    [self handleNetConnectionPacket];
}

- (void)tcpSocketDidConnected:(nonnull VCTCPSocket *)socket {
    /// Pass
}

@end
