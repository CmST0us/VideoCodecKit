//
//  VCDemoVideoAudioSyncViewController.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/11/6.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import <VideoCodecKit/VideoCodecKit.h>
#import "VCDemoVideoAudioSyncViewController.h"

@interface VCDemoVideoAudioSyncViewController ()

@end

@implementation VCDemoVideoAudioSyncViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    VCAUAACAudioDecoderConfig *config = [[VCAUAACAudioDecoderConfig alloc] init];
    NSLog(@"%@", config);
    // Do any additional setup after loading the view.
}



@end
