//
//  VCSafeObjectQueue.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/21.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import "VCSafeObjectQueue.h"
#import <sys/time.h>

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

- (VCSafeObjectQueue *)initWithSize:(int)size{
    self = [super init];
    if (self) {
        pthread_mutex_init(&_mutex, NULL);
        pthread_cond_init(&_cond, NULL);
        
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

- (void)clear{
    pthread_mutex_lock(&_mutex);
    _head = 0;
    _tail = 0;
    _count = 0;
    [_node removeAllObjects];
    pthread_mutex_unlock(&_mutex);
}

- (BOOL)push:(NSObject *)object {
    pthread_mutex_lock(&_mutex);
    if(object == nil || [self isFull]){
        pthread_mutex_unlock(&_mutex);
        return NO;
    }
    _node[_tail] = object;
    _tail++;
    if(_tail >= _size) _tail = 0;
    _count++;
    pthread_cond_signal(&_cond);
    pthread_mutex_unlock(&_mutex);
    return YES;
}

- (NSObject *)pull{
    pthread_mutex_lock(&_mutex);
    if(_count == 0)
    {
        struct timeval tv;
        gettimeofday(&tv, NULL);
        
        struct timespec ts;
        ts.tv_sec = tv.tv_sec + 2;
        ts.tv_nsec = tv.tv_usec*1000;
        pthread_cond_timedwait(&_cond, &_mutex, &ts);
        if(_count == 0)
        {
            pthread_mutex_unlock(&_mutex);
            return NULL;
        }
    }
    
    NSObject *tmp = [_node objectAtIndex:_head];
    _head++;
    if(_head>=_size)_head = 0;
    _count--;
    pthread_mutex_unlock(&_mutex);
    return tmp;
}

- (void)wakeupReader{
    pthread_mutex_lock(&_mutex);
    pthread_cond_signal(&_cond);
    pthread_mutex_unlock(&_mutex);
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
