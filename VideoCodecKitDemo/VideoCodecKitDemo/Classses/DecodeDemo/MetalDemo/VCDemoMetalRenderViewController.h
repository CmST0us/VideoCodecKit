//
//  VCDemoMetalRenderViewController.h
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/10/31.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "VCDemoBackableViewController.h"

@interface VCDemoMetalRenderViewController : VCDemoBackableViewController
@property (nonatomic , strong) AVCaptureSession *captureSession; //负责输入和输出设备之间的数据传递
@property (nonatomic , strong) AVCaptureDeviceInput *captureDeviceInput;//负责从AVCaptureDevice获得输入数据
@property (nonatomic , strong) AVCaptureVideoDataOutput *captureDeviceOutput; //
- (void)startCapture;
- (void)stopCapture;
@end
