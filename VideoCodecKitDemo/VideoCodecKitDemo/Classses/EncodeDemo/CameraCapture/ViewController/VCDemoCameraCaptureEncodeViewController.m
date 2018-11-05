//
//  VCDemoCameraCaptureEncodeViewController.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/10/30.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import "VCDemoCameraCaptureEncodeViewController.h"
#import "VCDemoCameraCaptureController.h"
#import <VideoCodecKit/VCAutoResizeLayerView.h>

@interface VCDemoCameraCaptureEncodeViewController ()
@property (nonatomic, strong) UIButton *captureButton;
@property (nonatomic, strong) VCAutoResizeLayerView *previewView;
@property (nonatomic, strong) VCDemoCameraCaptureController *captureController;
@property (nonatomic , strong) AVCaptureVideoPreviewLayer *previewLayer;
@end

@implementation VCDemoCameraCaptureEncodeViewController

#pragma mark - Override

- (void)customInit {
    [super customInit];
    
    [self createViews];
    [self setupViews];
    [self createConstraints];
    
    self.captureController = [[VCDemoCameraCaptureController alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - Private

- (void)createViews {
    self.captureButton = [[UIButton alloc] init];
    [self.view addSubview:self.captureButton];
    self.previewView = [[VCAutoResizeLayerView alloc] init];
    [self.view addSubview:self.previewView];
}

- (void)setupViews {
    [self.captureButton setBackgroundColor:[UIColor clearColor]];
    [self.captureButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.captureButton setTitle:NSLocalizedString(@"拍摄", nil) forState:UIControlStateNormal];
    [self.captureButton sizeToFit];
    [self.captureButton addTarget:self action:@selector(onCaptureButtonClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)createConstraints {
    [self.captureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.baseline.mas_equalTo(self.backButton.mas_baseline);
        make.right.mas_equalTo(self.view.mas_rightMargin).offset(-4);
    }];
    
    [self.previewView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.captureButton.mas_bottom).offset(8);
    }];
}

#pragma mark - Lift Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.captureButton setTitle:[self.captureController nextStatusActionTitle] forState:UIControlStateNormal];
}

#pragma mark - Action
- (void)onCaptureButtonClick:(UIButton *)button {
    if (self.captureController.currentStatus == VCDemoCameraCaptureStatusRunning) {
        [self.captureController stopCapture];
        [self.previewLayer removeFromSuperlayer];
        [button setTitle:[self.captureController nextStatusActionTitle] forState:UIControlStateNormal];
    } else {
        [self.captureController startCapture];
        self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureController.captureSession];
        [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        [self.previewLayer setFrame:self.previewView.bounds];
        [self.previewView addAutoResizeSubLayer:self.previewLayer];
        [self statusBarOrientationChange:nil];
        
        [button setTitle:[self.captureController nextStatusActionTitle] forState:UIControlStateNormal];
    }
}

- (void)onBack:(UIButton *)button {
    [super onBack:button];
    [self.captureController stopCapture];
}

- (void)statusBarOrientationChange:(NSNotification *)notification{
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (interfaceOrientation == UIInterfaceOrientationPortrait) {
        [self.previewLayer.connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    } else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        [self.previewLayer.connection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
    } else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        [self.previewLayer.connection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
    }
}

@end
