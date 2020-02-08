//
//  VCRTMPNetStream_Private.h
//  VideoCodecKit
//
//  Created by CmST0us on 2020/2/8.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import "VCRTMPNetStream.h"
#import "VCRTMPCommandMessageCommand.h"

@class VCRTMPNetConnection;
@interface VCRTMPNetStream ()
@property (nonatomic, copy) NSString *streamName;
@property (nonatomic, assign) uint32_t streamID;
@property (nonatomic, copy) VCRTMPCommandMessageResponseBlock responseBlock;

@property (nonatomic, weak) VCRTMPNetConnection *netConnection;

@end
