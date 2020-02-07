//
//  VCRTMPNetConnection_Private.h
//  VideoCodecKit
//
//  Created by CmST0us on 2020/2/7.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import "VCRTMPNetConnection.h"
#import "VCRTMPCommandMessageCommand.h"

@interface VCRTMPNetConnection ()
@property (nonatomic, copy) VCRTMPCommandMessageResponseBlock resultBlock;
@property (nonatomic, weak) VCRTMPSession *session;

- (void)handleConnectionResult:(VCRTMPCommandMessageResponse *)result;
@end
