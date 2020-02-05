//
//  VCRTMPHandshake.h
//  VideoCodecKit
//
//  Created by CmST0us on 2019/2/12.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCTCPSocket.h"

NS_ASSUME_NONNULL_BEGIN

extern NSErrorDomain const VCRTMPHandshakeErrorDomain;
typedef NS_ENUM(NSInteger, VCRTMPHandshakeErrorCode) {
    VCRTMPHandshakeErrorCodeConnectTimeout = -1000,
    VCRTMPHandshakeErrorCodeUnknow = -1001,
    VCRTMPHandshakeErrorCodeConnectReset = -1002,
    VCRTMPHandshakeErrorCodeConnectError = -1003,
    VCRTMPHandshakeErrorCodeVerifyS0S1 = -1004,
    VCRTMPHandshakeErrorCodeVerifyS2 = -1005,
};

typedef NS_ENUM(NSUInteger, VCRTMPHandshakeState) {
    VCRTMPHandshakeStateUninitialized,
    VCRTMPHandshakeStateVersionSent,
    VCRTMPHandshakeStateAckSent,
    VCRTMPHandshakeStateHandshakeDone,
    VCRTMPHandshakeStateError
};

@class VCRTMPHandshake;
typedef void(^VCRTMPHandshakeBlock)(VCRTMPHandshake *handshake, BOOL isSuccess, NSError * _Nullable  error);

@class VCRTMPSocket;
@interface VCRTMPHandshake : NSObject
@property (nonatomic, readonly) VCRTMPHandshakeState state;

#pragma mark - RTMP Handshake Property
@property (nonatomic, assign) uint8_t version;

/**
 默认初始化方法

 @param socket 需要握手的套接字
 @return handshake实例
 */
+ (instancetype)handshakeForSocket:(VCTCPSocket *)socket;

- (void)startHandshakeWithBlock:(VCRTMPHandshakeBlock)block;

@end

NS_ASSUME_NONNULL_END
