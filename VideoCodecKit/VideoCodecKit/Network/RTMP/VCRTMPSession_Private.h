//
//  VCRTMPSession_Private.h
//  VideoCodecKit
//
//  Created by CmST0us on 2020/2/6.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import "VCRTMPSession.h"
#import "VCRTMPChunkChannel.h"

@class VCRTMPCommandMessageTask;
@interface VCRTMPSession () <VCRTMPChunkChannelDelegate>

@property (nonatomic, assign) NSUInteger transactionIDCounter;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, VCRTMPCommandMessageTask *> *commandMessageTasks;

@property (nonatomic, strong) VCRTMPChunkChannel *channel;
@property (nonatomic, strong) VCRTMPNetConnection *netConnection;

- (NSUInteger)nextTransactionID;

- (void)respondWindowAcknowledgmentWithSize:(uint32_t)size;

+ (NSDictionary<NSNumber *, NSString *> *)protocolControlMessageHandlerMap;
+ (NSDictionary<NSString *, NSString *> *)commandMessageHandlerMap;
@end
