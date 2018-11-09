//
//  VCSafeBuffer.m
//  VideoCodecKit
//
//  Created by CmST0us on 2018/11/9.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import <pthread.h>
#import "VCSafeObjectQueue.h"
#import "VCSafeBuffer.h"

#define kVCPerformIfNeedThreadSafe(__code__) if (_isThreadSafe) { __code__;}

#define kVCSafeBufferMaxDataQueueSize (50)

@interface VCSafeBuffer () {
    pthread_mutex_t _lock;
}
@property (nonatomic, strong) VCSafeObjectQueue *dataQueue;
@property (nonatomic, assign) int dataCount;
@end

@implementation VCSafeBufferNode
- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        _data = data;
        _readOffset = 0;
    }
    return self;
}

- (NSData *)pull:(NSInteger *)length {
    NSInteger pullLength = MIN(self.data.length - _readOffset, *length);
    if (pullLength == 0) {
        return nil;
    }
    NSData *pullData = [self.data subdataWithRange:NSMakeRange(_readOffset, pullLength)];
    *length = pullData.length;
    _readOffset += pullData.length;
    return pullData;
}

- (NSInteger)length {
    return self.data.length;
}

- (NSInteger)readableLength {
    return self.data.length - self.readOffset;
}

@end

@implementation VCSafeBuffer

- (instancetype)initWithThreadSafe:(BOOL)isThreadSafe {
    self = [super init];
    if (self) {
        _isThreadSafe = isThreadSafe;
        _canWrite = YES;
        _shouldWaitWhenPullFailed = YES;
        kVCPerformIfNeedThreadSafe(pthread_mutex_init(&_lock, NULL));
        _dataQueue = [[VCSafeObjectQueue alloc] initWithSize:kVCSafeBufferMaxDataQueueSize threadSafe:isThreadSafe];
        _dataCount = 0;
    }
    return self;
}

- (void)clear {
    kVCPerformIfNeedThreadSafe(pthread_mutex_lock(&_lock));
    [_dataQueue clear];
    _dataCount = 0;
    kVCPerformIfNeedThreadSafe(pthread_mutex_unlock(&_lock));
}

- (int)count {
    return self.dataCount;
}

- (BOOL)push:(VCSafeBufferNode *)data {
    if (data == nil || data.readableLength == 0) return NO;
    kVCPerformIfNeedThreadSafe(pthread_mutex_lock(&_lock));
    BOOL ret = [_dataQueue push:data];
    if (ret) {
        _dataCount += data.readableLength;
    }
    kVCPerformIfNeedThreadSafe(pthread_mutex_unlock(&_lock));
    return ret;
}


- (NSData *)pull:(NSInteger *)length {
    kVCPerformIfNeedThreadSafe(pthread_mutex_lock(&_lock));
    NSInteger desiredLength = *length;
    NSMutableData *totalData = [[NSMutableData alloc] initWithCapacity:desiredLength];
    NSInteger pullLength = 0;
    while (pullLength < desiredLength) {
        NSInteger lastLength = desiredLength - pullLength;
        VCSafeBufferNode *data = (VCSafeBufferNode *)[self.dataQueue fetch];
        if (data == nil || ![data isKindOfClass:[VCSafeBufferNode class]]) {
            break;
        } else if (data.readableLength == 0) {
            // 丢空Node
            [self.dataQueue pull];
        } else {
            if (data.readableLength <= lastLength) {
                // 读完, 丢这个node
                NSInteger readFromNode = data.readableLength;
                pullLength += data.readableLength;
                [totalData appendData:[data pull:&readFromNode]];
                [self.dataQueue pull];
            } else {
                // 不用读完
                NSInteger readFromNode = lastLength;
                pullLength += lastLength;
                [totalData appendData:[data pull:&readFromNode]];
            }
        }
    }
    *length = pullLength;
    kVCPerformIfNeedThreadSafe(pthread_mutex_unlock(&_lock));
    return totalData;
}

- (NSData *)fetch:(NSInteger *)length {
    kVCPerformIfNeedThreadSafe(pthread_mutex_lock(&_lock));
    VCSafeBufferNode *data = (VCSafeBufferNode *)[self.dataQueue fetch];
    NSInteger readLen = MIN(data.readableLength, *length);
    *length = readLen;
    kVCPerformIfNeedThreadSafe(pthread_mutex_unlock(&_lock));
    return [data.data subdataWithRange:NSMakeRange(data.readOffset, readLen)];
}

- (void)wakeupReader {
    if (_isThreadSafe) {
        pthread_mutex_lock(&_lock);
        [self.dataQueue wakeupReader];
        pthread_mutex_unlock(&_lock);
    }
}

@end
