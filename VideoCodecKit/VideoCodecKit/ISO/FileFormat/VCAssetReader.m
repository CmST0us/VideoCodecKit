//
//  VCAssetReader.m
//  VideoCodecKit
//
//  Created by CmST0us on 2020/1/27.
//  Copyright © 2020 eric3u. All rights reserved.
//

#import "VCAssetReader.h"

@implementation VCAssetReader

- (instancetype)init {
    self = [super init];
    if (self) {
        _audioFormatDescription = NULL;
        _videoFormatDescription = NULL;
    }
    return self;
}

@end
