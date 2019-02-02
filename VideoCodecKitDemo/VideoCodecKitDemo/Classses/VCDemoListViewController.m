//
//  VCDemoListViewController.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/10/31.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import "VCDemoListViewController.h"
#import "VCDemoISOTestViewController.h"

typedef NS_ENUM(NSUInteger, VCDemoListItem) {
    VCDemoListItemISO,
    
    VCDemoListItemCount,
};
@interface VCDemoListViewController ()

@end

@implementation VCDemoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)onDemoItemButtonClick:(UIButton *)sender {
    NSInteger tag = sender.tag;
    switch (tag) {
        case VCDemoListItemISO: {
            VCDemoISOTestViewController *vc = [[VCDemoISOTestViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        default:
        break;
    }
}

@end
