//
//  VCRTMPHandshake.h
//  VideoCodecKit
//
//  Created by CmST0us on 2019/2/12.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, VCRTMPHandshakeState) {
    VCRTMPHandshakeStateUninitialized = 0,
    
    VCRTMPHandshakeStateVersionSending = 1,
    VCRTMPHandshakeStateVersionSent = 2,
    
    VCRTMPHandshakeStateAckSending = 3,
    VCRTMPHandshakeStateAckSent = 4,
    
    VCRTMPHandshakeStateHandshakeDone = 5,
};

@class VCRTMPHandshake;
typedef void(^VCRTMPHandshakeBlock)(VCRTMPHandshake *handshake, BOOL isSuccess, NSError *error);

@interface VCRTMPHandshake : NSObject {
    BOOL _isError;
}
@property (nonatomic, assign) VCRTMPHandshakeState state;

- (void)startHandshakeWithBlock:(VCRTMPHandshakeBlock)block;
#pragma mark - State Trans Method;
/**
 发送C0 C1握手包
 状态变化:
 
 0 -> 1
 发送C0C1
 1 -> 2

 */
- (void)sendC0C1;


/**
 收到S0 S1后开始发送C2
 状态变化:
 
 收到 S0 和 S1
 2 -> 3
 发送C2
 3 -> 4
 */
- (void)continueSendAck;


/**
 收到 S2 后完成握手
 状态变化:
 
 收到 S2
 4 -> 5
 */
- (void)makeHandshakeDone;

@end

NS_ASSUME_NONNULL_END
