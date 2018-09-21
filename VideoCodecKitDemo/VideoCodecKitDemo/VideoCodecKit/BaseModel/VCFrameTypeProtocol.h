//
//  VCFrameTypeProtocol.h
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/9.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#ifndef VCFrameTypeProtocol_h
#define VCFrameTypeProtocol_h

@class NSString;
@class NSObject;
@protocol VCFrameTypeProtocol<NSObject>
@required
- (NSString *)frameClassString;
- (void *)context;
@end

#endif /* VCFrameTypeProtocol_h */
