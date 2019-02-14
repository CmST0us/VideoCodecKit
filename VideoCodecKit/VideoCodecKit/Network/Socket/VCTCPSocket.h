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

/**
 所有使用VCTCPSocket的子类应继承此接口
 对此socket的读写请使用 使用此socket的对象 的读写方法
 */
@protocol VCTCPComm <NSObject>
- (VCTCPSocket *)socket;
@end

@protocol VCTCPSocketDelegate <NSObject>
- (void)tcpSocketConnectTimeout:(VCTCPSocket *)socket;
- (void)tcpSocketDidConnected:(VCTCPSocket *)socket;
- (void)tcpSocketHasByteAvailable:(VCTCPSocket *)socket;
- (void)tcpSocketErrorOccurred:(VCTCPSocket *)socket;
- (void)tcpSocketEndcountered:(VCTCPSocket *)socket;
@end

@interface VCTCPSocket : NSObject

@property (nonatomic, weak) id<VCTCPSocketDelegate> delegate;

@property (nonatomic, assign) BOOL connected;

@property (nonatomic, assign) NSTimeInterval timeout;
@property (nonatomic, assign) NSInteger inputBufferWindowSize;

@property (nonatomic, strong, nullable) NSInputStream *inputStream;
@property (nonatomic, strong, nullable) NSOutputStream *outputStream;

@property (nonatomic, readonly) NSInteger byteAvaliable;

- (void)connectWithHost:(NSString *)host
                   port:(NSUInteger)port;

- (void)close;

- (void)writeData:(NSData *)data;
- (nullable NSData *)readData;
@end

NS_ASSUME_NONNULL_END
