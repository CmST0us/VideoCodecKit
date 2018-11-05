//
//  VideoCodecKitTools.m
//  VideoCodecKit
//
//  Created by CmST0us on 2018/10/31.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import "VideoCodecKitTools.h"

@implementation NSBundle (VideoCodecKitBundle)

+ (NSBundle *)videoCodecKitBundle {
    NSBundle *frameworkBundle = [NSBundle bundleWithPath:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Frameworks/VideoCodecKit.framework"]];
    return frameworkBundle;
}

@end

@implementation VideoCodecKitTools

@end
