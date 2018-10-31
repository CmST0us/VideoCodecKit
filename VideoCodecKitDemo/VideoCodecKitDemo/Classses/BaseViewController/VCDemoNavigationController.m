//
//  VCDemoNavigationController.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/10/30.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import "VCDemoNavigationController.h"

@interface VCDemoNavigationController ()

@end

@implementation VCDemoNavigationController

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    [self setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}


@end
