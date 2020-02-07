//
//  VCRTMPSession+CommandMessageHandler.h
//  VideoCodecKit
//
//  Created by CmST0us on 2020/2/7.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import "VCRTMPSession.h"
NS_ASSUME_NONNULL_BEGIN

@class VCRTMPCommandMessageCommand;
@interface VCRTMPSession (CommandMessageHandler)

- (void)registerTransactionID:(NSUInteger)transactionID
                     observer:(NSObject *)observer
                      handler:(SEL)handler;

- (void)removeTransactionIDTask:(NSUInteger)transactionID;

- (void)handleAMF0Command:(VCRTMPChunk *)chunk;

- (void)handleCommandMessageResponse:(VCRTMPChunk *)chunk;
@end

NS_ASSUME_NONNULL_END
