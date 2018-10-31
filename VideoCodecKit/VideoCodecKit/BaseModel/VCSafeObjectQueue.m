//
//  VCSafeObjectQueue.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/21.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import "VCSafeObjectQueue.h"
#import <sys/time.h>

#define kVCPerformIfNeedThreadSafe(__code__) if (_isThreadSafe) { __code__;}

@interface VCSafeObjectQueue () {
    // node
    NSMutableArray *_node;
    // total size of the queue
    int _size;
    // number of nodes
    int _count;
    int _head;
    int _tail;
    
    pthread_mutex_t _mutex;
    pthread_cond_t _cond;
}

@end

@implementation VCSafeObjectQueue

- (instancetype)initWithSize:(int)size threadSafe:(BOOL)isThreadSafe {
    self = [super init];
    if (self) {
        _isThreadSafe = isThreadSafe;
        _shouldWaitWhenPullFailed = YES;
        kVCPerformIfNeedThreadSafe(pthread_mutex_init(&_mutex, NULL));
        kVCPerformIfNeedThreadSafe(pthread_cond_init(&_cond, NULL));
        
        _head = 0;
        _tail = 0;
        _count = 0;
        _size = 0;
        _node = NULL;
        if (size <= 0) return self;
        _size = size;
        _node = [[NSMutableArray alloc] initWithCapacity:_size];
    }
    return self;
}

- (instancetype)initWithSize:(int)size{
    return [self initWithSize:size threadSafe:YES];
}

- (void)clear{
    kVCPerformIfNeedThreadSafe(pthread_mutex_lock(&_mutex));
    _head = 0;
    _tail = 0;
    _count = 0;
    [_node removeAllObjects];
    kVCPerformIfNeedThreadSafe(pthread_mutex_unlock(&_mutex));
}

- (BOOL)push:(NSObject *)object {
    kVCPerformIfNeedThreadSafe(pthread_mutex_lock(&_mutex));
    if(object == nil || [self isFull]){
        kVCPerformIfNeedThreadSafe(pthread_mutex_unlock(&_mutex));
        return NO;
    }
    _node[_tail] = object;
    _tail++;
    if(_tail >= _size) _tail = 0;
    _count++;
    kVCPerformIfNeedThreadSafe(pthread_cond_signal(&_cond));
    kVCPerformIfNeedThreadSafe(pthread_mutex_unlock(&_mutex));
    return YES;
}

- (NSObject *)pull{
    kVCPerformIfNeedThreadSafe(pthread_mutex_lock(&_mutex));
    if(_count == 0)
    {
        if (!_shouldWaitWhenPullFailed) {
            kVCPerformIfNeedThreadSafe(pthread_mutex_unlock(&_mutex));
            return NULL;
        }
        
        struct timeval tv;
        gettimeofday(&tv, NULL);
        
        struct timespec ts;
        ts.tv_sec = tv.tv_sec + 1;
        ts.tv_nsec = tv.tv_usec * 1000;
        kVCPerformIfNeedThreadSafe(pthread_cond_timedwait(&_cond, &_mutex, &ts));
        if(_count == 0)
        {
            kVCPerformIfNeedThreadSafe(pthread_mutex_unlock(&_mutex));
            return NULL;
        }
    }
    
    NSObject *tmp = [_node objectAtIndex:_head];
    _head++;
    if(_head>=_size)_head = 0;
    _count--;
    kVCPerformIfNeedThreadSafe(pthread_mutex_unlock(&_mutex));
    return tmp;
}

- (void)wakeupReader{
    kVCPerformIfNeedThreadSafe(pthread_mutex_lock(&_mutex));
    kVCPerformIfNeedThreadSafe(pthread_cond_signal(&_cond));
    kVCPerformIfNeedThreadSafe(pthread_mutex_unlock(&_mutex));
}

- (int)count{
    return _count;
}

- (int)size{
    return _size;
}

- (bool)isFull{
    if(_count == _size){
        return YES;
    }
    else{
        return NO;
    }
}
@end
