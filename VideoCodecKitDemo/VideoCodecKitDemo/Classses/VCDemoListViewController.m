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
#import "VCDemoMetalRenderViewController.h"
#import "VCDemoVideoAudioSyncViewController.h"
#import "VCDemoISOTestViewController.h"

typedef NS_ENUM(NSUInteger, VCDemoListItem) {
    VCDemoListItemCameraCaptureEncode = 0,
    VCDemoListItemH264Decode,
    VCDemoListItemMetalRender,
    VCDemoListItemVideoAudioSync,
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
#if (TARGET_IPHONE_SIMULATOR)
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"不支持" message:@"模拟器不支持Metal" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:cancelAction];
            [self presentViewController:alert animated:YES completion:nil];
#else
            VCDemoMetalRenderViewController *vc = [[VCDemoMetalRenderViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
#endif
        }
        break;
            
        case VCDemoListItemVideoAudioSync: {
            VCDemoVideoAudioSyncViewController *vc = [[VCDemoVideoAudioSyncViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            
        break;
            
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
