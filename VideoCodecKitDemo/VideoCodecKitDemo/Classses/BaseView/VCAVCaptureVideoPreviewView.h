//
//  VCAVCaptureVideoPreviewView.h
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/10/31.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VCAVCaptureVideoPreviewView : UIView
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@end

NS_ASSUME_NONNULL_END
