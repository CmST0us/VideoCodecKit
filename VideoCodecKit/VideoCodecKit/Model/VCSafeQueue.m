//
//  VCSafeQueue.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/21.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import "VCSafeQueue.h"
#import <sys/time.h>

#define kVCPerformIfNeedThreadSafe(__code__) if (_isThreadSafe) { __code__;}

typedef struct{
    uint8_t *ptr;
    int size;
} VCLinkNode;

@interface VCSafeQueue () {
    // node
    VCLinkNode *_node;
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

@implementation VCSafeQueue

- (instancetype)initWithSize:(int)size
                  threadSafe:(BOOL)isThreadSafe {
    self = [super init];
    if (self) {
        _isThreadSafe = isThreadSafe;
        kVCPerformIfNeedThreadSafe(pthread_mutex_init(&_mutex, NULL));
        kVCPerformIfNeedThreadSafe(pthread_cond_init(&_cond, NULL));
        
        _head = 0;
        _tail = 0;
        _count = 0;
        _size = 0;
        _node = NULL;
        if (size <= 0) return self;
        _size = size;
        _node = (VCLinkNode *)malloc(size * sizeof(VCLinkNode));
    }
    return self;
}

- (instancetype)initWithSize:(int)size{
    return [self initWithSize:size threadSafe:YES];
}

- (void)dealloc {
    if (_node) {
        free(_node);
        _node = NULL;
    }
}
- (void)clear{
    kVCPerformIfNeedThreadSafe(pthread_mutex_lock(&_mutex));
    int idx = 0;
    for(int i = 0; i<_count; i++){
        if(i + _head >= _size){
            idx = i + _head -_size;
        } else {
            idx = i + _head;
        }
        if(_node[idx].ptr != NULL){
            free(_node[idx].ptr);
            _node[idx].ptr = NULL;
        }
        _node[idx].size = 0;
    }
    _head = 0;
    _tail = 0;
    _count = 0;
    kVCPerformIfNeedThreadSafe(pthread_mutex_unlock(&_mutex));
}

- (BOOL)push:(uint8_t *)buf length:(int)len{
    kVCPerformIfNeedThreadSafe(pthread_mutex_lock(&_mutex));
    if(len == 0 || buf == NULL || [self isFull]){
        kVCPerformIfNeedThreadSafe(pthread_mutex_unlock(&_mutex));
        return NO;
    }
    _node[_tail].ptr = buf;
    _node[_tail].size = len;
    _tail++;
    if(_tail >= _size) _tail = 0;
    _count++;
    kVCPerformIfNeedThreadSafe(pthread_cond_signal(&_cond));
    kVCPerformIfNeedThreadSafe(pthread_mutex_unlock(&_mutex));
    return YES;
}

- (uint8_t *)pull:(int *)len{
    kVCPerformIfNeedThreadSafe(pthread_mutex_lock(&_mutex));
    if(_count == 0)
    {
        struct timeval tv;
        gettimeofday(&tv, NULL);
        
        struct timespec ts;
        ts.tv_sec = tv.tv_sec + 1;
        ts.tv_nsec = tv.tv_usec * 1000;
        kVCPerformIfNeedThreadSafe(pthread_cond_timedwait(&_cond, &_mutex, &ts));
        if(_count == 0)
        {
            *len = 0;
            kVCPerformIfNeedThreadSafe(pthread_mutex_unlock(&_mutex));
            return NULL;
        }
    }
    uint8_t *tmp = NULL;
    tmp = _node[_head].ptr;
    *len = _node[_head].size;
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

- (BOOL)isFull{
    if(_count == _size){
        return YES;
    }
    else{
        return NO;
    }
}
@end
