//
//  VCRTMPSession_Private.h
//  VideoCodecKit
//
//  Created by CmST0us on 2020/2/6.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import "VCRTMPSession.h"
#import "VCRTMPChunkStreamSpliter.h"
@interface VCRTMPSession () <VCRTMPChunkStreamSpliterDelegate>
@property (nonatomic, strong) VCRTMPChunkStreamSpliter *spliter;
@end
