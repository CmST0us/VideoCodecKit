//
//  VCImageTypeProtocol.h
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/20.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>

@protocol VCImageTypeProtocol <NSObject>
@required
- (NSString *)classStringForImageType;
- (CVPixelBufferRef)pixelBuffer;
- (void)setPixelBuffer:(CVPixelBufferRef)pixelBuffer;
@end
