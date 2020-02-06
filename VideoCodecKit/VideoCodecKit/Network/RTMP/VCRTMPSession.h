//
//  VCRTMPSession.h
//  VideoCodecKit
//
//  Created by CmST0us on 2019/2/3.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCRTMPChunk.h"
NS_ASSUME_NONNULL_BEGIN

@class VCTCPSocket;
@class VCRTMPNetConnection;
extern NSErrorDomain const VCRTMPSessionErrorDomain;
typedef NS_ENUM(NSUInteger, VCRTMPSessionErrorCode) {
    VCRTMPSessionErrorCodeUnknow = -3000,
};
@interface VCRTMPSession : NSObject

+ (instancetype)sessionForSocket:(VCTCPSocket *)socket;

- (void)setChunkSize:(uint32_t)size;
- (void)setPeerBandwidth:(uint32_t)bandwidth limitType:(VCRTMPChunkSetPeerBandwidthLimitType)limitType;
- (void)abortMessage:(uint32_t)streamID;

- (VCRTMPNetConnection *)makeNetConnection;
@end

NS_ASSUME_NONNULL_END
