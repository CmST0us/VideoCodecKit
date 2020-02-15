//
//  VCRTMPNetConnection.h
//  VideoCodecKit
//
//  Created by CmST0us on 2020/2/5.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCRTMPCommandMessageCommand.h"
NS_ASSUME_NONNULL_BEGIN

@class VCRTMPSession;
extern NSErrorDomain const VCRTMPNetConnectionErrorDomain;
typedef NS_ENUM(NSUInteger, VCRTMPNetConnectionErrorCode) {
    VCRTMPNetConnectionErrorCodeUnknow = -2000,
    VCRTMPNetConnectionErrorCodeConnectReset = -2001,
    VCRTMPNetConnectionErrorCodeConnectError = -2002,
};

@class VCRTMPNetStream;
@interface VCRTMPNetConnection : NSObject

+ (instancetype)netConnectionForSession:(VCRTMPSession *)session;

- (void)connecWithParam:(NSDictionary *)param completion:(VCRTMPCommandMessageResponseBlock)block;
- (void)releaseStream:(NSString *)streamName;
- (void)createStream:(NSString *)streamName completion:(VCRTMPCommandMessageResponseBlock)block;

- (VCRTMPNetStream *)makeNetStreamWithStreamName:(NSString *)streamName
                                        streamID:(uint32_t)streamID;

- (void)end;
@end

NS_ASSUME_NONNULL_END
