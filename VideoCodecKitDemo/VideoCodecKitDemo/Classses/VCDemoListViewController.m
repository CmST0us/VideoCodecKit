//
//  VCDemoListViewController.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/10/31.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import "VCDemoListViewController.h"
#import "VCDemoDecodeSBDLViewController.h"
#import "VCDemoCameraCaptureEncodeViewController.h"

typedef NS_ENUM(NSUInteger, VCDemoListItem) {
    VCDemoListItemCameraCaptureEncode = 0,
    VCDemoListItemH264Decode,
    VCDemoListItemMetalRender,
    
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
        case VCDemoListItemCameraCaptureEncode: {
            VCDemoCameraCaptureEncodeViewController *vc = [[VCDemoCameraCaptureEncodeViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
        break;
        
        case VCDemoListItemH264Decode: {
            VCDemoDecodeSBDLViewController *vc = [[VCDemoDecodeSBDLViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
        break;

        case VCDemoListItemMetalRender: {
//            VCDemoDecodeSBDLViewController *vc = [[VCDemoDecodeSBDLViewController alloc] init];
//            [self.navigationController pushViewController:vc animated:YES];
        }
        break;
            
            
        default:
        break;
    }
}

@end
