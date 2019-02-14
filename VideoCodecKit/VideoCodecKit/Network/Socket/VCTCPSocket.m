//
//  VCTCPSocket.m
//  VideoCodecKit
//
//  Created by CmST0us on 2019/2/12.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "VCTCPSocket.h"

#define kVCTCPSocketDefaultTimeout (15)
#define kVCTCPSocketDefaultBufferWindowSize (UINT16_MAX)
@interface VCTCPSocket () <NSStreamDelegate>
@property (nonatomic, strong) NSTimer *timeoutTimer;
@property (nonatomic, assign) uint8_t *inputBuffer;
@property (nonatomic, strong) dispatch_queue_t inputQueue;
@property (nonatomic, strong) dispatch_queue_t outputQueue;
@property (nonatomic, strong) NSRunLoop *runloop;
@end

@implementation VCTCPSocket
@synthesize inputBufferWindowSize = _inputBufferWindowSize;

- (instancetype)init {
    self = [super init];
    if (self) {
        _inputQueue = dispatch_queue_create("com.VideoCodecKit.VCTCPSocket.inputQueue", DISPATCH_QUEUE_SERIAL);
        _outputQueue = dispatch_queue_create("com.VideoCodecKit.VCTCPSocket.ouputQueue", DISPATCH_QUEUE_SERIAL);
        _timeout = kVCTCPSocketDefaultTimeout;
        _connected = NO;
        _runloop = nil;
        _inputBufferWindowSize = kVCTCPSocketDefaultBufferWindowSize;
        _inputBuffer = nil;
    }
    return self;
}

- (void)setInputBufferWindowSize:(NSInteger)inputBufferWindowSize {
    if (inputBufferWindowSize <= 0) {
        return;
    }
    _inputBufferWindowSize = inputBufferWindowSize;
    _inputBuffer = realloc(self.inputBuffer, self.inputBufferWindowSize);
}

- (uint8_t *)inputBuffer {
    if (_inputBuffer != nil) {
        return _inputBuffer;
    }
    _inputBuffer = malloc(_inputBufferWindowSize);
    return _inputBuffer;
}

- (void)dealloc {
    if (_inputBuffer != nil) {
        free(_inputBuffer);
        _inputBuffer = nil;
    }
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

- (void)finishConnect {
    self.connected = YES;
    [self.timeoutTimer invalidate];
    self.timeoutTimer = nil;
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
        self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:self.timeout repeats:NO block:^(NSTimer * _Nonnull timer) {
            if (!self.connected &&
                self.delegate &&
                [self.delegate respondsToSelector:@selector(tcpSocketConnectTimeout:)]) {
                [self.delegate tcpSocketConnectTimeout:self];
            }
        }];
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

- (void)writeData:(NSData *)data {
    dispatch_async(self.outputQueue, ^{
        if (self.outputStream == nil || !self.connected) {
            return;
        }
        [self.outputStream write:data.bytes maxLength:data.length];
    });
}

- (NSData *)readData {
    NSData *data = nil;
    NSInteger readLen = [self.inputStream read:self.inputBuffer maxLength:self.inputBufferWindowSize];
    if (readLen > 0) {
        data = [[NSData alloc] initWithBytes:self.inputBuffer length:readLen];
    }
    return data;
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) {
        case NSStreamEventOpenCompleted: {
            if (self.inputStream &&
                self.outputStream &&
                self.inputStream.streamStatus == NSStreamStatusOpen &&
                self.outputStream.streamStatus == NSStreamStatusOpen) {
                if (aStream == self.inputStream) {
                    [self finishConnect];
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
            [self finishConnect];
            if (aStream == self.inputStream) {
                if (self.delegate &&
                    [self.delegate respondsToSelector:@selector(tcpSocketErrorOccurred:)]) {
                    [self.delegate tcpSocketErrorOccurred:self];
                }
            }
        }
            break;
        case NSStreamEventEndEncountered: {
            if (aStream == self.inputStream) {
                if (self.delegate &&
                    [self.delegate respondsToSelector:@selector(tcpSocketEndcountered:)]) {
                    [self.delegate tcpSocketEndcountered:self];
                }
            }
        }
            break;
        default:
            break;
    }
}

@end
