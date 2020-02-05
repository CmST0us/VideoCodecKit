//
//  VCRTMPNetConnection.h
//  VideoCodecKit
//
//  Created by CmST0us on 2020/2/5.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCTCPSocket.h"

NS_ASSUME_NONNULL_BEGIN

extern NSErrorDomain const VCRTMPNetConnectionErrorDomain;
typedef NS_ENUM(NSUInteger, VCRTMPNetConnectionErrorCode) {
    VCRTMPNetConnectionErrorCodeUnknow = -2000,
    VCRTMPNetConnectionErrorCodeConnectReset = -2001,
    VCRTMPNetConnectionErrorCodeConnectError = -2002,
};

@interface VCRTMPNetConnection : NSObject

+ (instancetype)netConnectionForSocket:(VCTCPSocket *)socket;

- (void)connecWithParam:(NSDictionary *)param;
@end

NS_ASSUME_NONNULL_END
