//
//  VCRTMPChunkChannel.h
//  VideoCodecKit
//
//  Created by CmST0us on 2020/2/6.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCRTMPChunk.h"
#import "VCTCPSocket.h"

NS_ASSUME_NONNULL_BEGIN

@class VCRTMPChunkChannel;
@protocol VCRTMPChunkChannelDelegate <NSObject>
- (void)channel:(VCRTMPChunkChannel *)channel didReceiveFrame:(VCRTMPChunk *)chunk;
- (void)channelNeedAck:(VCRTMPChunkChannel *)channel;
- (void)channelConnectionDidEnd;
- (void)channel:(VCRTMPChunkChannel *)channel connectionHasError:(NSError *)error;
@end

@interface VCRTMPChunkChannel : NSObject

@property (nonatomic, readonly) NSUInteger totalRecvByte;
@property (nonatomic, readonly) NSUInteger totalSendByte;

@property (nonatomic, assign) NSUInteger localChunkSize;
@property (nonatomic, assign) NSUInteger remoteChunkSize;
@property (nonatomic, assign) NSUInteger acknowlegmentWindowSize;
@property (nonatomic, assign) NSUInteger bandwidth;

@property (nonatomic, weak) id<VCRTMPChunkChannelDelegate> delegate;

+ (instancetype)channelForSocket:(VCTCPSocket *)socket;

- (void)writeFrame:(VCRTMPChunk *)chunk;

- (void)resetRecvByteCount;
- (void)resetSendByteCount;
- (void)useCurrntAcknowlegmentWindowSizeAsBandwidth;

@end

NS_ASSUME_NONNULL_END
