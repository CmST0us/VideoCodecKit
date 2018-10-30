//
//  VCDemoCameraCaptureController.h
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/10/30.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VideoCodecKit/VideoCodecKit.h>

typedef NS_ENUM(NSUInteger, VCDemoCameraCaptureStatus) {
    VCDemoCameraCaptureStatusReady,
    // |
    // | 拍摄
    VCDemoCameraCaptureStatusRunning,
    // |
    // | 停止拍摄
    VCDemoCameraCaptureStatusStop,
    // ->拍摄
};

@interface VCDemoCameraCaptureController : NSObject

@property (nonatomic , strong) AVCaptureSession *captureSession; //负责输入和输出设备之间的数据传递
@property (nonatomic , strong) AVCaptureDeviceInput *captureDeviceInput;//负责从AVCaptureDevice获得输入数据
@property (nonatomic , strong) AVCaptureVideoDataOutput *captureDeviceOutput; //

@property (nonatomic, readonly) VCDemoCameraCaptureStatus currentStatus;
@property (nonatomic, strong) VCVTH264Encoder *encoder;

@property (nonatomic, copy) NSString *outputFile;

- (void)startCapture;
- (void)stopCapture;

- (NSString *)nextStatusActionTitle;


@end

