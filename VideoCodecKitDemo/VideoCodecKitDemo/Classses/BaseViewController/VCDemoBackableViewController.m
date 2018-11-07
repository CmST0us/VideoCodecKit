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
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_leftMargin).offset(4);
        make.top.mas_equalTo(self.view.mas_topMargin).offset(8);
        make.height.mas_equalTo(20);
    }];
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
