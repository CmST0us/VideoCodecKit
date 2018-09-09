//
//  ViewController.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/8.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <KVSig/KVSig.h>

#import "ViewController.h"
#import "VCDecodeController.h"

@interface ViewController ()
@property (nonatomic, strong) VCDecodeController *decoderController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.decoderController = [[VCDecodeController alloc] init];
    self.decoderController.parseFilePath = @"/Users/cmst0us/Desktop/swift.h264";
    [self bindData];
}


- (void)bindData {
    weakSelf(target);
    [self.decoderController addKVSigObserver:self forKeyPath:KVSKeyPath([self decoderController].parser.pasrseCount) handle:^(NSObject *oldValue, NSObject *newValue) {
        NSLog(@"%@", target.decoderController.parser.currentParseFrame);
    }];
    
    [self.decoderController addKVSigObserver:self forKeyPath:KVSKeyPath([self decoderController].parser.currentParseFrame) handle:^(NSObject *oldValue, NSObject *newValue) {
        NSLog(@"%@", newValue);
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.decoderController startParse];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.decoderController stopParse];
//        [NSThread sleepForTimeInterval:1];
//        [self.decoderController.parser reset];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
