//
//  VCRTMPSocket.h
//  VideoCodecKit
//
//  Created by CmST0us on 2019/2/12.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCTCPSocket.h"

NS_ASSUME_NONNULL_BEGIN
@class VCRTMPSocket;
@protocol VCRTMPSocketDelegate <NSObject>
- (void)rtmpSocketDidConnected:(VCRTMPSocket *)rtmpSocket;
- (void)rtmpSocketConnectedTimeout:(VCRTMPSocket *)rtmpSocket;
- (void)rtmpSocketErrorOccurred:(VCRTMPSocket *)rtmpSocket;
@end

@interface VCRTMPSocket : NSObject<VCTCPComm>

@property (nonatomic, weak) id<VCRTMPSocketDelegate> delegate;

@property (nonatomic, readonly) BOOL connected;
@property (nonatomic, assign) NSTimeInterval timeout;

- (void)connectHost:(NSString *)host
           withPort:(NSInteger)port;

- (void)close;

- (void)writeData:(NSData *)data;
- (NSData *)readData;

@end

NS_ASSUME_NONNULL_END
