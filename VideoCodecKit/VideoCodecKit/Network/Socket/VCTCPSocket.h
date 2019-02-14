//
//  VCTCPSocket.h
//  VideoCodecKit
//
//  Created by CmST0us on 2019/2/12.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class VCTCPSocket;
@protocol VCTCPSocketDelegate <NSObject>
- (void)tcpSocketConnectTimeout:(VCTCPSocket *)socket;
- (void)tcpSocketDidConnected:(VCTCPSocket *)socket;
- (void)tcpSocketHasByteAvailable:(VCTCPSocket *)socket;
- (void)tcpSocketOpenCompleted:(VCTCPSocket *)socket;
- (void)tcpSocketErrorOccurred:(VCTCPSocket *)socket;
- (void)tcpSocketEncountered:(VCTCPSocket *)socket;
@end

@interface VCTCPSocket : NSObject

@property (nonatomic, weak) id<VCTCPSocketDelegate> delegate;

@property (nonatomic, assign) BOOL connected;
@property (nonatomic, assign) NSTimeInterval timeout;

@property (nonatomic, strong, nullable) NSInputStream *inputStream;
@property (nonatomic, strong, nullable) NSOutputStream *outputStream;

- (void)connectWithHost:(NSString *)host
                   port:(NSUInteger)port;

- (void)close;

@end

NS_ASSUME_NONNULL_END
