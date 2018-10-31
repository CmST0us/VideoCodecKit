//
//  VCDemoBackableViewController.h
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/10/30.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import "VCDemoViewController.h"
@interface VCDemoBackableViewController : VCDemoViewController
@property (nonatomic, strong) UIButton *backButton;

- (void)onBack:(UIButton *)button;

@end
