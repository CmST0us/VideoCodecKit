    //
//  VCRTMPPublisher.m
//  VideoCodecKit
//
//  Created by CmST0us on 2020/2/15.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import "VCRTMPPublisher.h"
#import "VCRTMPSession.h"
#import "VCTCPSocket.h"
#import "VCRTMPHandshake.h"
#import "VCRTMPNetConnection.h"
#import "VCRTMPCommandMessageCommand.h"
#import "VCActionScriptTypes.h"
#import "VCRTMPNetStream.h"
#import "VCRTMPChunk.h"
#import "VCFLVTag.h"
#import "VCRTMPMessage.h"

#define VCRTMPPublisherChunkSize (4096)

NSString * const VCRTMPPublishURLProtocolRTMP = @"rtmp";

NSErrorDomain const VCRTMPPublisherErrorDomain = @"VCRTMPPublisherErrorDomain";

@interface VCRTMPPublisher ()
@property (nonatomic, assign) VCRTMPPublisherState state;

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, copy) NSString *publishKey;
@property (nonatomic, readonly) NSString *host;
@property (nonatomic, readonly) NSString *port;
@property (nonatomic, readonly) NSString *appName;

@property (nonatomic, strong) VCRTMPHandshake *handshake;
@property (nonatomic, strong) VCRTMPSession *session;
@property (nonatomic, strong) VCRTMPNetConnection *connection;
@property (nonatomic, strong) VCRTMPNetStream *stream;
@property (nonatomic, strong) VCTCPSocket *socket;

@property (nonatomic, assign) uint32_t lastAudioTimestamp;
@property (nonatomic, assign) uint32_t lastVideoTimestamp;
@property (nonatomic, assign) BOOL hasPublishVideo;
@property (nonatomic, assign) BOOL hasPublishAudio;
@end

@implementation VCRTMPPublisher

- (instancetype)initWithURL:(NSURL *)url publishKey:(NSString *)publishKey {
    self = [super init];
    if (self) {
        _url = url;
        _publishKey = publishKey;
        _state = VCRTMPPublisherStateInit;
    }
    return self;
}

- (void)start {
    kVCAllowState(@[@(VCRTMPPublisherStateInit)], @(self.state));
    
    NSError *error = nil;
    self.hasPublishAudio = NO;
    self.hasPublishVideo = NO;
    self.lastAudioTimestamp = 0;
    self.lastVideoTimestamp = 0;
    
    do {
        if (![[self.url.scheme lowercaseString] isEqualToString:VCRTMPPublishURLProtocolRTMP]) {
            error = [NSError errorWithDomain:VCRTMPPublisherErrorDomain
                                        code:VCRTMPPublisherErrorCodeProtocolUnsupport
                                    userInfo:nil];
            break;
        }
        
        NSString *host = self.host;
        NSString *port = self.port;
        NSString *appName = self.appName;
        if (host == nil||
            port == nil ||
            appName == nil ||
            host.length == 0 ||
            port.length == 0 ||
            appName.length == 0) {
            error = [NSError errorWithDomain:VCRTMPPublisherErrorDomain
                                        code:VCRTMPPublisherErrorCodeBadURL
                                    userInfo:nil];
            break;
        }
        
        [self createSocketWithHost:host port:port];
        [self createHandeshake];
    } while (0);
    if (error) {
        self.state = VCRTMPPublisherStateError;
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(publisher:didChangeState:error:)]) {
            [self.delegate publisher:self didChangeState:VCRTMPPublisherStateError error:error];
        }
    }
    
    // Do Handshake
    __weak typeof(self) weakSelf = self;
    [self.handshake startHandshakeWithBlock:^(VCRTMPHandshake * _Nonnull handshake, VCRTMPSession * _Nullable session, BOOL isSuccess, NSError * _Nullable error) {
        if (isSuccess) {
            weakSelf.session= session;
            [weakSelf.session registerChannelCloseHandle:^(NSError * _Nonnull error) {
                [weakSelf handlePublishErrorWithCode:VCRTMPPublisherErrorCodeConnectionFailed];
            }];
            [weakSelf handleHandshakeSuccess];
        } else {
            [weakSelf handlePublishErrorWithCode:VCRTMPPublisherErrorCodeHandshakeFailed];
        }
    }];
}

- (void)stop {
    [self.session end];
    self.state = VCRTMPPublisherStateEnd;
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(publisher:didChangeState:error:)]) {
        [self.delegate publisher:self didChangeState:VCRTMPPublisherStateEnd error:nil];
    }
}

- (void)writeTag:(VCFLVTag *)tag {
    kVCAllowState(@[@(VCRTMPPublisherStateReadyToPublish)], @(self.state));
    
    if (tag.tagType == VCFLVTagTypeAudio) {
        VCRTMPChunk *audioChunk = [VCRTMPChunk makeAudioChunk];
        audioChunk.chunkData = tag.payloadDataWithoutExternTimestamp;
        audioChunk.messageHeaderType = self.hasPublishAudio ? VCRTMPChunkMessageHeaderType1 : VCRTMPChunkMessageHeaderType0;
        audioChunk.message.messageStreamID = self.stream.streamID;
        audioChunk.message.timestamp = (uint32_t)(tag.extendedTimestamp - self.lastAudioTimestamp);
        self.lastAudioTimestamp = tag.extendedTimestamp;
        [self.stream writeChunk:audioChunk];
        if (!self.hasPublishAudio) {
            self.hasPublishAudio = YES;
        }
    } else if (tag.tagType == VCFLVTagTypeVideo) {
        VCRTMPChunk *videoChunk = [VCRTMPChunk makeVideoChunk];
        videoChunk.chunkData = tag.payloadDataWithoutExternTimestamp;
        videoChunk.messageHeaderType = self.hasPublishVideo ? VCRTMPChunkMessageHeaderType1 : VCRTMPChunkMessageHeaderType0;
        videoChunk.message.messageStreamID = self.stream.streamID;
        videoChunk.message.timestamp = (uint32_t)(tag.extendedTimestamp - self.lastVideoTimestamp);
        [self.stream writeChunk:videoChunk];
        self.lastVideoTimestamp = tag.extendedTimestamp;
        if (!self.hasPublishVideo) {
            self.hasPublishVideo = YES;
        }
    }
}

#pragma mark - Getter
- (NSString *)host {
    return self.url.host;
}

- (NSString *)port {
    NSString *port = self.url.port.stringValue;
    if (port == nil) {
        port = @(kVCRTMPPort).stringValue;
    }
    return port;
}

- (NSString *)appName {
    NSString *appName = [self.url relativePath];
    if (appName &&
        [appName hasPrefix:@"/"]) {
        appName = [appName substringFromIndex:1];
    }
    return appName;
}

#pragma mark - Private
- (void)createSocketWithHost:(NSString *)host
                        port:(NSString *)port {
    self.socket = [[VCTCPSocket alloc] initWithHost:host port:port.integerValue];
}

- (void)createHandeshake {
    self.handshake = [VCRTMPHandshake handshakeForSocket:self.socket];
}

#pragma mark - Handle
- (void)handlePublishErrorWithCode:(VCRTMPPublisherErrorCode)code {
    self.state = VCRTMPHandshakeStateError;
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(publisher:didChangeState:error:)]) {
        NSError *error = [NSError errorWithDomain:VCRTMPPublisherErrorDomain code:code userInfo:nil];
        [self.delegate publisher:self didChangeState:VCRTMPPublisherStateError error:error];
    }
    [self stop];
}

- (void)handleHandshakeSuccess {
    self.connection = [self.session makeNetConnection];
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *param = self.connectionParameter.mutableCopy;
    [param addEntriesFromDictionary:@{
        @"app": self.appName.asString,
        @"tcUrl": self.url.absoluteString.asString
    }];
    [self.connection connecWithParam:param
                          completion:^(VCRTMPCommandMessageResponse * _Nullable response, BOOL isSuccess) {
        if (isSuccess) {
            [weakSelf handleConnectionSuccess];
        } else {
            [weakSelf handlePublishErrorWithCode:VCRTMPPublisherErrorCodeConnectionFailed];
        }
    }];
}

- (void)handleConnectionSuccess {
    __weak typeof(self) weakSelf = self;
    [self.connection releaseStream:self.publishKey];
    [self.connection createStream:self.publishKey completion:^(VCRTMPCommandMessageResponse * _Nullable response, BOOL isSuccess) {
        if (isSuccess) {
            VCRTMPNetConnectionCommandCreateStreamResult *result = (VCRTMPNetConnectionCommandCreateStreamResult *)response;
            [weakSelf handleCreateStreamSuccessWithStreamID:(uint32_t)result.streamID.integerValue];
        } else {
            [weakSelf handlePublishErrorWithCode:VCRTMPPublisherErrorCodeCreateNetStreamFailed];
        }
    }];
}

- (void)handleCreateStreamSuccessWithStreamID:(uint32_t)streamID {
    __weak typeof(self) weakSelf = self;
    self.stream = [self.connection makeNetStreamWithStreamName:self.publishKey streamID:streamID];
    [self.stream publishWithCompletion:^(VCRTMPCommandMessageResponse * _Nullable response, BOOL isSuccess) {
        if (isSuccess) {
            [weakSelf handlePublishStreamSuccess];
        } else {
            [weakSelf handlePublishErrorWithCode:VCRTMPPublisherErrorCodePublishStreamFailed];
        }
    }];
}

- (void)handlePublishStreamSuccess {
    if (self.streamMetaData) {
        [self.stream setMetaData:self.streamMetaData];
    }
    [self handlePublishStartSuccess];
}

- (void)handlePublishStartSuccess {
    self.state = VCRTMPPublisherStateReadyToPublish;
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(publisher:didChangeState:error:)]) {
        [self.delegate publisher:self didChangeState:VCRTMPPublisherStateReadyToPublish error:nil];
    }
}
@end
