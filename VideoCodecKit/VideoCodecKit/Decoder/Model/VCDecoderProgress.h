//
//  VCDecoderProgress.h
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/9.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class VCVideoFPS;
@interface VCDecoderProgress : NSObject
@property (nonatomic, readonly) VCVideoFPS *fps;
@property (nonatomic, assign) NSUInteger frameCount;
@end
NS_ASSUME_NONNULL_END
