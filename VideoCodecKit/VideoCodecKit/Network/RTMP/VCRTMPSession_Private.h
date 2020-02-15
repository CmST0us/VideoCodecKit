//
//  VCRTMPSession_Private.h
//  VideoCodecKit
//
//  Created by CmST0us on 2020/2/6.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import "VCRTMPSession.h"
#import "VCRTMPChunkChannel.h"


@interface VCRTMPCommandMessageTask : NSObject
@property (nonatomic, weak) id observer;
@property (nonatomic, assign) SEL handler;
@property (nonatomic, assign) NSUInteger transactionID;
@end

@interface VCRTMPNetStreamMessageTask : NSObject
@property (nonatomic, weak) id observer;
@property (nonatomic, assign) SEL handler;
@property (nonatomic, assign) NSUInteger messageStreamID;
@end

@interface VCRTMPSession () <VCRTMPChunkChannelDelegate>

@property (nonatomic, copy) VCRTMPSessionChannelCloseHandle channelCloseHandle;

@property (nonatomic, assign) NSUInteger transactionIDCounter;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, VCRTMPCommandMessageTask *> *commandMessageTasks;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, VCRTMPNetStreamMessageTask *> *netStreamMessageTasks;

@property (nonatomic, strong) VCRTMPChunkChannel *channel;
@property (nonatomic, strong) VCRTMPNetConnection *netConnection;

- (NSUInteger)nextTransactionID;

- (void)respondWindowAcknowledgmentWithSize:(uint32_t)size;

+ (NSDictionary<NSNumber *, NSString *> *)protocolControlMessageHandlerMap;
+ (NSDictionary<NSString *, NSString *> *)commandMessageHandlerMap;
@end
