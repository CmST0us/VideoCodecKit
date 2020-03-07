//
//  VCDemoBackableViewController.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/10/30.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import "VCDemoBackableViewController.h"

@interface VCDemoBackableViewController ()

@end

@implementation VCDemoBackableViewController

#pragma mmark - Override
- (void)customInit {
    [super customInit];
}

#pragma mark - Private Method
- (void)createBackButton {
    self.backButton = [[UIButton alloc] init];
    [self.view addSubview:self.backButton];
}

- (void)setupBackButton {
    [self.backButton setBackgroundColor:[UIColor clearColor]];
    [self.backButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.backButton.titleLabel setFont:[UIFont systemFontOfSize:15 weight:UIFontWeightBold]];
    [self.backButton setTitle:NSLocalizedString(@"返回", nil) forState:UIControlStateNormal];
    [self.backButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [self.backButton addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.backButton sizeToFit];
}

- (void)createBackButtonConstraints {
    self.backButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.backButton.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:4].active = YES;
    [self.backButton.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:8].active = YES;
    [self.backButton.heightAnchor constraintEqualToConstant:20].active = YES;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createBackButton];
    [self setupBackButton];
    [self createBackButtonConstraints];
}

#pragma mark - Action
- (void)onBack:(UIButton *)button {
    UINavigationController *nav = self.navigationController;
    if (nav) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
