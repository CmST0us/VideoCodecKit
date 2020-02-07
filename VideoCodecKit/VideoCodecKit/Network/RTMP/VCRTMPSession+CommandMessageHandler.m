//
//  VCRTMPSession+CommandMessageHandler.m
//  VideoCodecKit
//
//  Created by CmST0us on 2020/2/7.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import "VCRTMPSession+CommandMessageHandler.h"
#import "VCRTMPSession_Private.h"
#import "VCRTMPNetConnection_Private.h"
#import "VCRTMPCommandMessageCommand.h"
#import "VCRTMPChunk.h"
#import "VCRTMPMessage.h"

@implementation VCRTMPSession (CommandMessageHandler)

- (void)registerTransactionID:(NSUInteger)transactionID
                     observer:(NSObject *)observer
                      handler:(SEL)handler {
    VCRTMPCommandMessageTask *task = [[VCRTMPCommandMessageTask alloc] init];
    task.transactionID = transactionID;
    task.observer = observer;
    task.handler = handler;
    [self.commandMessageTasks setObject:task forKey:@(transactionID)];
}

- (void)removeTransactionIDTask:(NSUInteger)transactionID {
    [self.commandMessageTasks removeObjectForKey:@(transactionID)];
}

- (void)handleAMF0Command:(VCRTMPChunk *)chunk {
    NSString *commandType = chunk.commandTypeValue;
    NSLog(@"[RTMP][CHANNEL] Command: %@", commandType);
    NSString *handler = [[self class] commandMessageHandlerMap][commandType];
    if (handler) {
        SEL selector = NSSelectorFromString(handler);
        if (selector &&
            [self respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self performSelector:selector withObject:chunk];
#pragma clang diagnostic pop
        }
    }
}

- (void)handleCommandMessageResponse:(VCRTMPChunk *)chunk {
    NSUInteger transactionID = chunk.transactionIDValue.unsignedIntegerValue;
    VCRTMPCommandMessageTask *task = [self.commandMessageTasks objectForKey:@(transactionID)];
    if (task &&
        task.observer &&
        task.handler) {
        VCRTMPCommandMessageResponse *response = [[VCRTMPCommandMessageResponse alloc] initWithData:chunk.chunkData];
        [response deserialize];
        if ([task.observer respondsToSelector:task.handler]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [task.observer performSelector:task.handler withObject:response];
#pragma clang diagnostic pop
        }
    }
    [self removeTransactionIDTask:transactionID];
}

@end
