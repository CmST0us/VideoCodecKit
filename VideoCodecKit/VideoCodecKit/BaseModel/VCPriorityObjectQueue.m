//
//  VCPriorityObjectQueue.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/26.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <pthread.h>
#import <objc/runtime.h>
#import <sys/time.h>
#import "VCPriorityObjectQueue.h"

#define kVCPerformIfNeedThreadSafe(__code__) if (_isThreadSafe) { __code__;}

static const char *kVCPriorityObjectRuntimePriorityKey = "kVCPriorityObjectRuntimePriorityKey";
static const char *kVCPriorityObjectRuntimeNextKey = "kVCPriorityObjectRuntimeNextKey";
static const char *kVCPriorityObjectRuntimeLastKey = "kVCPriorityObjectRuntimeLastKey";

@interface VCPriorityObjectQueue () {
    int _size;
    int _count;
    
    // 队列锁
    pthread_mutex_t _mutex;
    // 互斥锁
    pthread_cond_t _cond;
}
@property (nonatomic, strong) NSObject *head;
@property (nonatomic, strong) NSObject *tail;
@end

@implementation VCPriorityObjectQueue

- (NSInteger)priorityOfObject:(NSObject *)object {
    id priorityObj = objc_getAssociatedObject(object, kVCPriorityObjectRuntimePriorityKey);
    if ([priorityObj isKindOfClass:[NSNumber class]]) {
        return [priorityObj integerValue];
    }
    return -1;
}

- (void)setPriority:(NSInteger)priority
           toObject:(NSObject *)object {
    objc_setAssociatedObject(object, kVCPriorityObjectRuntimePriorityKey, @(priority), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSObject *)nextObjectOfObject:(NSObject *)object {
    return objc_getAssociatedObject(object, kVCPriorityObjectRuntimeNextKey);
}

- (void)setNextObjext:(NSObject *)nextObject
             toObject:(NSObject *)object {
    objc_setAssociatedObject(object, kVCPriorityObjectRuntimeNextKey, nextObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSObject *)lastObjectOfObject:(NSObject *)object {
    return objc_getAssociatedObject(object, kVCPriorityObjectRuntimeLastKey);
}

- (void)setLastObjext:(NSObject *)lastObject
             toObject:(NSObject *)object {
    objc_setAssociatedObject(object, kVCPriorityObjectRuntimeLastKey, lastObject, OBJC_ASSOCIATION_ASSIGN);
}

- (instancetype)initWithSize:(int)size
                isThreadSafe:(BOOL)isThreadSafe {
    self = [super init];
    if (self) {
        _isThreadSafe = isThreadSafe;
        
        kVCPerformIfNeedThreadSafe(pthread_mutex_init(&_mutex, NULL));
        kVCPerformIfNeedThreadSafe(pthread_cond_init(&_cond, NULL));
        
        _head = NULL;
        _tail = NULL;
        _count = 0;
        _size = size;
        _willEnd = NO;
    }
    return self;
}

- (void)clear {
    kVCPerformIfNeedThreadSafe(pthread_mutex_lock(&_mutex));
    
    _head = nil;
    _tail = nil;
    _count = 0;
    _willEnd = NO;
    kVCPerformIfNeedThreadSafe(pthread_mutex_unlock(&_mutex));
}

- (BOOL)push:(NSObject *)object
    priority:(NSInteger)priority {
    kVCPerformIfNeedThreadSafe(pthread_mutex_lock(&_mutex));
    if (object == nil || [self isFull]) {
        kVCPerformIfNeedThreadSafe(pthread_mutex_unlock(&_mutex));
        return NO;
    }
    
    // set priority to object
    [self setPriority:priority toObject:object];
    
    if (_head == nil) {
        _head = object;
        _tail = object;
    } else if ([self priorityOfObject:object] == kVCPriorityIDR) {
        [self setNextObjext:object toObject:_tail];
        [self setLastObjext:_tail toObject:object];
        _tail = object;
    } else {
        // insert by priority
        NSObject *insertBehind = _tail;
        
        while (insertBehind != nil) {
            if ([self priorityOfObject:insertBehind] == kVCPriorityIDR) {
                break;
            }
            
            if ([self priorityOfObject:insertBehind] <= [self priorityOfObject:object]) {
                break;
            }
            
            //prev
            insertBehind = [self lastObjectOfObject:insertBehind];
        }
        
        if (insertBehind == nil) {
            // insert to head
            [self setNextObjext:_head toObject:object];
            [self setLastObjext:object toObject:_head];
            _head = object;
        } else {
            // insert behind
            // 如果是IDR, 或者和前一帧优先级相同的帧，直接接在最后一个图像后面
            [self setNextObjext:[self nextObjectOfObject:insertBehind] toObject:object];
            [self setLastObjext:insertBehind toObject:object];
            
            [self setNextObjext:object toObject:insertBehind];
            if ([self nextObjectOfObject:object]) {
                [self setLastObjext:object toObject:[self nextObjectOfObject:object]];
            } else {
                _tail = object;
            }
        }
    }
    
    _count ++;
    kVCPerformIfNeedThreadSafe(pthread_cond_signal(&_cond));
    kVCPerformIfNeedThreadSafe(pthread_mutex_unlock(&_mutex));
    return YES;
}

- (NSObject *)pull {
    kVCPerformIfNeedThreadSafe(pthread_mutex_lock(&_mutex));
    if (_count <= _watermark) {
        if (_isThreadSafe == NO || _willEnd == YES) {
            kVCPerformIfNeedThreadSafe(pthread_mutex_unlock(&_mutex));
            return nil;
        }
        
        struct timeval tv;
        gettimeofday(&tv, NULL);
        
        struct timespec ts;
        ts.tv_sec = tv.tv_sec + 2;
        ts.tv_nsec = tv.tv_usec*1000;
        kVCPerformIfNeedThreadSafe(pthread_cond_timedwait(&_cond, &_mutex, &ts));
        if(_count <= _watermark)
        {
            kVCPerformIfNeedThreadSafe(pthread_mutex_unlock(&_mutex));
            return NULL;
        }
        
    }
    // pop head
    NSObject *node = _head;
    
    if (node) {
        _head = [self nextObjectOfObject:node];
        if (_head) {
            [self setLastObjext:[NSNull null] toObject:_head];
        } else {
            _tail = nil;
        }
    }
    _count--;
    kVCPerformIfNeedThreadSafe(pthread_mutex_unlock(&_mutex));
    return node;
}

- (void)wakeupReader {
    if (_isThreadSafe) {
        pthread_mutex_lock(&_mutex);
        pthread_cond_signal(&_cond);
        pthread_mutex_unlock(&_mutex);
    }
}

- (int)count {
    return _count;
}

- (int)size {
    return _size;
}

- (BOOL)isFull {
    if (_count == _size) {
        return YES;
    }
    return NO;
}
@end
