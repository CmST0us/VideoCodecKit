//
//  VCRTMPNetStream.h
//  VideoCodecKit
//
//  Created by CmST0us on 2020/2/8.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCRTMPCommandMessageCommand.h"

NS_ASSUME_NONNULL_BEGIN

@class VCRTMPNetConnection;
@interface VCRTMPNetStream : NSObject

@property (nonatomic, readonly) NSString *streamName;
@property (nonatomic, readonly) uint32_t streamID;

+ (instancetype)netStreamWithName:(NSString *)streamName
                         streamID:(uint32_t)streamID
                 forNetConnection:(VCRTMPNetConnection *)netConnection;

- (void)publishWithCompletion:(VCRTMPCommandMessageResponseBlock)block;
@end

NS_ASSUME_NONNULL_END
