//
//  VCAudioRender.m
//  VideoCodecKit
//
//  Created by CmST0us on 2018/11/8.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import "VCAudioRender.h"
#import "VCAudioFrame.h"

@interface VCAudioRender ()

@end

@implementation VCAudioRender

- (NSArray<NSString *> *)supportRenderClassName {
    return @[
             NSStringFromClass([VCAudioFrame class]),
             ];
}

@end
