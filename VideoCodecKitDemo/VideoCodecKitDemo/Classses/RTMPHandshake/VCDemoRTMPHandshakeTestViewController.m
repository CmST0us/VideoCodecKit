//
//  VCDemoRTMPHandshakeTestViewController.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2019/2/15.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <VideoCodecKit/VideoCodecKit.h>
#import "VCDemoRTMPHandshakeTestViewController.h"

@interface VCDemoRTMPHandshakeTestViewController ()
@property (nonatomic, strong) VCTCPSocket *socket;
@property (nonatomic, strong) VCRTMPHandshake *handshake;
@property (nonatomic, strong) VCRTMPSession *session;
@property (nonatomic, strong) VCRTMPNetConnection *netConnection;
@property (nonatomic, strong) VCRTMPNetStream *netStream;
@property (nonatomic, strong) VCFLVFile *flvFile;
@property (nonatomic, strong) dispatch_queue_t publishQueue;
@property (nonatomic, assign) BOOL hasPushAudio;
@property (nonatomic, assign) BOOL hasPushVideo;
@end

@implementation VCDemoRTMPHandshakeTestViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.socket = [[VCTCPSocket alloc] initWithHost:@"js.live-send.acg.tv" port:1935];
//    self.socket = [[VCTCPSocket alloc] initWithHost:@"127.0.0.1" port:1935];
    self.handshake = [VCRTMPHandshake handshakeForSocket:self.socket];
    
    self.publishQueue = dispatch_queue_create("Publish Queue", DISPATCH_QUEUE_SERIAL);
    self.hasPushAudio = NO;
    self.hasPushVideo = NO;
    __weak typeof(self) weakSelf = self;
    
    [self.handshake startHandshakeWithBlock:^(VCRTMPHandshake * _Nonnull handshake, VCRTMPSession * _Nullable session, BOOL isSuccess, NSError * _Nullable error) {
        if (isSuccess) {
            weakSelf.session = session;
            [weakSelf handleHandshakeSuccess];
        } else {
            NSLog(@"握手失败: %@", error);
        }
    }];
}

- (void)handleHandshakeSuccess {
    __weak typeof(self) weakSelf = self;
    self.netConnection = [self.session makeNetConnection];
    NSDictionary *parm = @{
        @"app": @"live-js".asString,
        @"tcUrl": @"rtmp://js.live-send.acg.tv/live-js/".asString,
        @"flashVer": @"FMLE/3.0 (compatible; FMSc/1.0)".asString,
        @"swfUrl": NSNull.asNull,
        @"fpad": @(NO).asBool,
        @"audioCodecs": @(0x0400).asNumber,
        @"videoCodecs": @(0x0080).asNumber,
        @"objectEncodeing": @(0).asNumber,
    };
    [self.netConnection connecWithParam:parm completion:^(VCRTMPCommandMessageResponse * _Nullable response, BOOL isSuccess) {
        if (isSuccess) {
            VCRTMPNetConnectionCommandConnectResult *result = (VCRTMPNetConnectionCommandConnectResult *)response;
            NSLog(@"[RTMP][NetConnection] Success: %@, %@", result.information, result.properties);
            [weakSelf handleNetConnectionSuccess];
        }
    }];
}

- (void)handleNetConnectionSuccess {
    __weak typeof(self) weakSelf = self;
    [self.netConnection releaseStream:@"?streamname=live_35432748_2964945&key=cb41bd28d62d79653f7d65721b1acb02"];
    [self.netConnection createStream:@"?streamname=live_35432748_2964945&key=cb41bd28d62d79653f7d65721b1acb02" completion:^(VCRTMPCommandMessageResponse * _Nullable response, BOOL isSuccess) {
//    [self.netConnection createStream:@"12345" completion:^(VCRTMPCommandMessageResponse * _Nullable response, BOOL isSuccess) {
        if (isSuccess) {
            NSLog(@"[RTMP][NetConnection][CreateStream] Success");
//            [weakSelf.session setChunkSize:8192];
            VCRTMPNetConnectionCommandCreateStreamResult *result = (VCRTMPNetConnectionCommandCreateStreamResult *)response;
            weakSelf.netStream = [weakSelf.netConnection makeNetStreamWithStreamName:@"?streamname=live_35432748_2964945&key=cb41bd28d62d79653f7d65721b1acb02" streamID:(uint32_t)result.streamID.unsignedIntegerValue];
            [weakSelf.netStream publishWithCompletion:^(VCRTMPCommandMessageResponse * _Nullable response, BOOL isSuccess) {
                [weakSelf.netStream setMetaData:@{
                    @"duration": @(0).asNumber,
                    @"fileSize": @(0).asNumber,
                    @"width": @(1280).asNumber,
                    @"height": @(720).asNumber,
                    @"videocodecid": @"avc1".asString,
                    @"videodatarate": @(2500).asNumber,
                    @"framerate": @(30).asNumber,
                    @"audiocodecid": @"mp4a".asString,
                    @"audiodatarate": @(160).asNumber,
                    @"audiosamplerate": @"44100".asString,
                    @"audiosamplesize": @(16).asNumber,
                    @"audiochannels": @(2).asNumber,
                    @"stereo": @(YES).asBool,
                    @"2.1": @(NO).asBool,
                    @"3.1": @(NO).asBool,
                    @"4.0": @(NO).asBool,
                    @"4.1": @(NO).asBool,
                    @"5.1": @(NO).asBool,
                    @"7.1": @(NO).asBool,
                    @"encoder": @"iOSVT::VideoCodecKit".asString,
                }];
                [weakSelf handleStartPublish];
            }];
        }
    }];
}

- (void)handleStartPublish {
    dispatch_async(self.publishQueue, ^{
        self.flvFile = [[VCFLVFile alloc] initWithURL:[[NSBundle mainBundle] URLForResource:@"test" withExtension:@"flv"]];
        VCFLVTag *tag = [self.flvFile nextTag];
        NSInteger lastVideoTimestamp = 0;
        NSInteger lastAudioTimestamp = 0;
        do {
            @autoreleasepool {
                if (tag.tagType == VCFLVTagTypeAudio) {
                    VCRTMPChunk *audioChunk = [VCRTMPChunk makeAudioChunk];
                    audioChunk.chunkData = tag.payloadDataWithoutExternTimestamp;
                    audioChunk.messageHeaderType = self.hasPushAudio ? VCRTMPChunkMessageHeaderType1 : VCRTMPChunkMessageHeaderType0;
                    audioChunk.message.messageStreamID = self.netStream.streamID;
                    audioChunk.message.timestamp = tag.timestamp - lastAudioTimestamp;
                    lastAudioTimestamp = tag.timestamp;
                    [self.netStream writeChunk:audioChunk];
                    self.hasPushAudio = YES;
                } else if (tag.tagType == VCFLVTagTypeVideo) {
                    VCRTMPChunk *videoChunk = [VCRTMPChunk makeVideoChunk];
                    videoChunk.chunkData = tag.payloadDataWithoutExternTimestamp;
                    videoChunk.messageHeaderType = self.hasPushVideo ? VCRTMPChunkMessageHeaderType1 : VCRTMPChunkMessageHeaderType0;
                    videoChunk.message.messageStreamID = self.netStream.streamID;
                    videoChunk.message.timestamp = tag.timestamp - lastVideoTimestamp;
                    [self.netStream writeChunk:videoChunk];
                    lastVideoTimestamp = tag.timestamp;
                    self.hasPushVideo = YES;
                }
                NSLog(@"push tag: %@", tag);
                tag = [self.flvFile nextTag];
                [NSThread sleepForTimeInterval:0.01];
            }
        } while (tag != nil);
        [self handleStartPublish];
    });
}
@end
