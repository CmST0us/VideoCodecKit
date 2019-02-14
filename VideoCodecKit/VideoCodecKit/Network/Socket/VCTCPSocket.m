//
//  VCTCPSocket.m
//  VideoCodecKit
//
//  Created by CmST0us on 2019/2/12.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "VCTCPSocket.h"

#define kVCTCPSocketDefaultTimeout (15)

@interface VCTCPSocket () <NSStreamDelegate>
@property (nonatomic, strong) dispatch_queue_t inputQueue;
@property (nonatomic, strong) dispatch_queue_t outputQueue;
@property (nonatomic, strong) NSRunLoop *runloop;
@end

@implementation VCTCPSocket

- (instancetype)init {
    self = [super init];
    if (self) {
        _inputQueue = dispatch_queue_create("com.VideoCodecKit.VCTCPSocket.inputQueue", DISPATCH_QUEUE_SERIAL);
        _outputQueue = dispatch_queue_create("com.VideoCodecKit.VCTCPSocket.ouputQueue", DISPATCH_QUEUE_SERIAL);
        _timeout = kVCTCPSocketDefaultTimeout;
        _connected = NO;
        _runloop = nil;
    }
    return self;
}

- (void)connectWithHost:(NSString *)host port:(NSUInteger)port {
    dispatch_async(self.inputQueue, ^{
        CFReadStreamRef readStream = nil;
        CFWriteStreamRef writeStream = nil;
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                           (__bridge CFStringRef)host,
                                           (UInt32)port,
                                           &readStream,
                                           &writeStream);
        if (readStream != nil && writeStream != nil) {
            self.connected = NO;
            self.inputStream = (__bridge NSInputStream *)CFRetain(readStream);
            self.outputStream = (__bridge NSOutputStream *)CFRetain(writeStream);
            [self setupConnection];
        }
    });
}

- (void)setupConnection {
    self.inputStream.delegate = self;
    self.outputStream.delegate = self;
    self.runloop = [NSRunLoop currentRunLoop];
    
    [self.inputStream scheduleInRunLoop:self.runloop forMode:NSDefaultRunLoopMode];
    [self.outputStream scheduleInRunLoop:self.runloop forMode:NSDefaultRunLoopMode];

    [self.inputStream open];
    [self.outputStream open];
    
    if (self.timeout > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.timeout * NSEC_PER_SEC)), self.outputQueue, ^{
            if (!self.connected &&
                self.delegate &&
                [self.delegate respondsToSelector:@selector(tcpSocketConnectTimeout:)]) {
                [self.delegate tcpSocketConnectTimeout:self];
            }
        });
    }
    
    [self.runloop run];
    self.connected = NO;
}

- (void)close {
    dispatch_async(self.outputQueue, ^{
        if (self.runloop == nil) {
            return;
        }
        [self.inputStream close];
        [self.inputStream removeFromRunLoop:self.runloop forMode:NSDefaultRunLoopMode];
        self.inputStream.delegate = nil;
        self.inputStream = nil;
        
        [self.outputStream close];
        [self.outputStream removeFromRunLoop:self.runloop forMode:NSDefaultRunLoopMode];
        self.outputStream.delegate = nil;
        self.outputStream = nil;
        
        CFRunLoopStop([self.runloop getCFRunLoop]);
        self.runloop = nil;
    });
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) {
        case NSStreamEventOpenCompleted: {
            if (self.inputStream &&
                self.outputStream &&
                self.inputStream.streamStatus == NSStreamStatusOpen &&
                self.outputStream.streamStatus == NSStreamStatusOpen) {
                if (aStream == self.inputStream) {
                    self.connected = YES;
                    if (self.delegate &&
                        [self.delegate respondsToSelector:@selector(tcpSocketDidConnected:)]) {
                        [self.delegate tcpSocketDidConnected:self];
                    }
                }
            }
        }
            break;
        case NSStreamEventHasBytesAvailable: {
            if (aStream == self.inputStream) {
                if (self.delegate &&
                    [self.delegate respondsToSelector:@selector(tcpSocketHasByteAvailable:)]) {
                    [self.delegate tcpSocketHasByteAvailable:self];
                }
            }
        }
            break;
        case NSStreamEventHasSpaceAvailable:
            break;
        case NSStreamEventErrorOccurred: {
            [self close];
        }
            break;
        case NSStreamEventEndEncountered: {
            [self close];
        }
            break;
        default:
            break;
    }
}

@end
