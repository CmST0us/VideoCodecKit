//
//  VCRawH265Reader.h
//  VideoCodecKit
//
//  Created by CmST0us on 2020/1/27.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import <VideoCodecKit/VideoCodecKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VCRawH265Reader : VCAssetReader

- (instancetype)initWithURL:(NSURL *)fileURL;

@end

NS_ASSUME_NONNULL_END
