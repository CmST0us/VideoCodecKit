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
}
@property (nonatomic, strong) NSCondition *condition;
@end

@implementation VCSafeObjectQueue

- (instancetype)initWithSize:(int)size threadSafe:(BOOL)isThreadSafe {
    self = [super init];
    if (self) {
        _isThreadSafe = isThreadSafe;
        _shouldWaitWhenPullFailed = YES;
        
        kVCPerformIfNeedThreadSafe(_condition = [[NSCondition alloc] init]);
        
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

- (instancetype)init {
    return [self initWithSize:10];
}

- (void)clear{
    kVCPerformIfNeedThreadSafe([_condition lock]);
    _head = 0;
    _tail = 0;
    _count = 0;
    [_node removeAllObjects];
    kVCPerformIfNeedThreadSafe([_condition unlock]);
}

- (BOOL)push:(NSObject *)object {
    kVCPerformIfNeedThreadSafe([_condition lock]);
    if(object == nil || [self isFull]){
        kVCPerformIfNeedThreadSafe([_condition unlock]);
        return NO;
    }
    _node[_tail] = object;
    _tail++;
    if(_tail >= _size) _tail = 0;
    _count++;
    kVCPerformIfNeedThreadSafe([_condition broadcast]);
    kVCPerformIfNeedThreadSafe([_condition unlock]);
    return YES;
}

- (NSObject *)pull{
    kVCPerformIfNeedThreadSafe([_condition lock]);
    if(_count == 0)
    {
        if (!_shouldWaitWhenPullFailed) {
            kVCPerformIfNeedThreadSafe([_condition unlock]);
            return NULL;
        }
        
        kVCPerformIfNeedThreadSafe([_condition waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]]);
        
        if(_count == 0) {
            kVCPerformIfNeedThreadSafe([_condition unlock]);
            return NULL;
        }
    }
    
    NSObject *tmp = [_node objectAtIndex:_head];
    _head++;
    if(_head>=_size)_head = 0;
    _count--;
    kVCPerformIfNeedThreadSafe([_condition unlock]);
    return tmp;
}

- (NSObject *)fetch {
    kVCPerformIfNeedThreadSafe([_condition lock]);
    if(_count == 0)
    {
        if (!_shouldWaitWhenPullFailed) {
            kVCPerformIfNeedThreadSafe([_condition unlock]);
            return NULL;
        }
        
        kVCPerformIfNeedThreadSafe([_condition waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]]);
        if(_count == 0) {
            kVCPerformIfNeedThreadSafe([_condition unlock]);
            return NULL;
        }
    }
    
    NSObject *tmp = [_node objectAtIndex:_head];
    kVCPerformIfNeedThreadSafe([_condition unlock]);
    return tmp;
}

- (void)wakeupReader{
    kVCPerformIfNeedThreadSafe([_condition broadcast]);
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

- (void)waitForCapacity {
    kVCPerformIfNeedThreadSafe([_condition wait]);
}

@end
