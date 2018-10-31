//
//  VCDemoViewController.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/10/30.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import "VCDemoViewController.h"

@interface VCDemoViewController ()

@end

@implementation VCDemoViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        [self customInit];
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)customInit {
    
}

@end
