//
//  VCAnnexBFormatParser.h
//  VideoCodecKit
//
//  Created by CmST0us on 2019/1/28.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class VCAnnexBFormatStream;
@interface VCAnnexBFormatParser : NSObject

- (void)appendData:(NSData *)data;
- (nullable VCAnnexBFormatStream *)next;
@end

NS_ASSUME_NONNULL_END
