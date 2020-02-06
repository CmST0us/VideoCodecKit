//
//  VCRTMPChunkStreamSpliter.h
//  VideoCodecKit
//
//  Created by CmST0us on 2020/2/6.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCRTMPChunk.h"
#import "VCTCPSocket.h"

NS_ASSUME_NONNULL_BEGIN

@class VCRTMPChunkStreamSpliter;
@protocol VCRTMPChunkStreamSpliterDelegate <NSObject>
- (void)spliter:(VCRTMPChunkStreamSpliter *)spliter didReceiveFrame:(VCRTMPChunk *)chunk;
- (void)spliterConnectionDidEnd;
- (void)spliter:(VCRTMPChunkStreamSpliter *)spliter connectionHasError:(NSError *)error;
@end

@interface VCRTMPChunkStreamSpliter : NSObject

@property (nonatomic, assign) NSInteger chunkDataDefaultSize;
@property (nonatomic, weak) id<VCRTMPChunkStreamSpliterDelegate> delegate;

+ (instancetype)spliterForSocket:(VCTCPSocket *)socket;

- (void)writeFrame:(VCRTMPChunk *)chunk;

@end

NS_ASSUME_NONNULL_END
