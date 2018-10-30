//
//  VCAVCaptureVideoPreviewView.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/10/31.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import "VCAVCaptureVideoPreviewView.h"

@implementation VCAVCaptureVideoPreviewView

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.captureVideoPreviewLayer setFrame:self.bounds];
}

@end
