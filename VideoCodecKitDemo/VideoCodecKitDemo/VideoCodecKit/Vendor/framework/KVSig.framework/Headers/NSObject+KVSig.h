//
//  NSObject+KVSig.h
//  KVSig
//
//  Created by CmST0us on 2018/8/17.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 实现了对KVO使用线程安全的Block监听
 */


// 支持自动填充KeyPath宏
#define KVSKeyPath(...) _keyPathSplit(@"" # __VA_ARGS__, __VA_ARGS__)
// 自动填充依赖函数
NSString *_keyPathSplit(NSString *p, ...);

// 弱引用宏
#define weakSelf(target) __weak typeof(self) target = self

/**
 监听器回调闭包
 
 @param oldValue 旧值
 @param newValue 新值
 */
typedef void(^KVSObserverBlock)(NSObject *oldValue, NSObject *newValue);

@class KVSEvaluation;
@interface NSObject (KVSig)

- (void)addKVSigObserver:(NSObject *)observer
              forKeyPath:(NSString *)keyPath
                  handle:(KVSObserverBlock)block;

- (void)addKVSigObserver:(NSObject *)observer
             forKeyPaths:(NSArray<NSString *> *)keyPaths
                  handle:(KVSObserverBlock)block;

- (void)removeKVSigObserver:(NSObject *)observer
                forKeyPaths:(NSArray<NSString *> *)keyPaths;

- (void)removeKVSigObserver:(NSObject *)observer
                 forKeyPath:(NSString *)keyPath;

- (void)removeKVSigObserver:(NSObject *)observer;

- (void)removeAllKVSigObserver;
    
- (KVSEvaluation *)evaluationForKeyPath:(NSString *)keyPath
                                 handle:(KVSObserverBlock)block;
@end
