//
//  VCAVCFormatStream.h
//  VideoCodecKit
//
//  Created by CmST0us on 2019/1/19.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
// Read stream as AVC format stream
// xx xx xx xx [4 bytes length] | xx xx xx xx .... [data]
// ------------------------------------------------------
// Convert stream to packet
@interface VCAVCFormatStream : NSObject

@end

NS_ASSUME_NONNULL_END
