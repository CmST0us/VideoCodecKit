//
//  VCAnnexBFormatStream.h
//  VideoCodecKit
//
//  Created by CmST0us on 2019/1/19.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
// Read as AnnexB format stream
// 00 00 00 01 xx xx xx ....
// 00 00 01 xx xx xx xx ....
// -----------------------------
// Conver stream to packet
@interface VCAnnexBFormatStream : NSObject

@end

NS_ASSUME_NONNULL_END
