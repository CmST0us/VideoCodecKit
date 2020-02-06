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
- (void)channelConnectionDidEnd;
- (void)channel:(VCRTMPChunkChannel *)channel connectionHasError:(NSError *)error;
@end

@interface VCRTMPChunkChannel : NSObject

@property (nonatomic, assign) NSInteger localChunkSize;
@property (nonatomic, assign) NSInteger remoteChunkSize;
@property (nonatomic, weak) id<VCRTMPChunkChannelDelegate> delegate;

+ (instancetype)channelForSocket:(VCTCPSocket *)socket;

- (void)writeFrame:(VCRTMPChunk *)chunk;

@end

NS_ASSUME_NONNULL_END
