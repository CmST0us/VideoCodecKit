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
#import "LYOpenGLView.h"

@interface ViewController ()
@property (nonatomic, strong) VCDecodeController *decoderController;
@property (nonatomic, strong) LYOpenGLView *glView;
@property (nonatomic, assign) NSInteger decodeFrameCount;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.decoderController = [[VCDecodeController alloc] init];
    self.decoderController.parseFilePath = @"/Users/eric.wu/Desktop/test.h264";
    
    self.glView = [[LYOpenGLView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.glView];
    [self.glView setupGL];
    [self bindData];
}


- (void)bindData {
    weakSelf(target);
    [self.decoderController addKVSigObserver:self forKeyPath:KVSKeyPath([self decoderController].frame) handle:^(NSObject *oldValue, NSObject *newValue) {
        VCH264Frame *frame = (VCH264Frame *)newValue;
            @autoreleasepool {
                CVPixelBufferRef pixelBuffer = [frame.image pixelBuffer];
                [target.glView displayPixelBuffer:pixelBuffer];
                CVPixelBufferRelease(pixelBuffer);
            }
//            NSString *filePath = [[NSString alloc] initWithFormat:@"/Users/eric.wu/Desktop/dump/%lu.yuv", (unsigned long)frame.frameIndex];
//            [[frame.image nv12PlaneData] writeToFile:filePath atomically:YES];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if ([self.decoderController.decoder.currentState isEqualToNumber:@(VCBaseDecoderStateRunning)]) {
        [self.decoderController stopParse];
    } else if ([self.decoderController.decoder.currentState isEqualToNumber:@(VCBaseDecoderStateStop)]) {
        [self.decoderController startParse];
    } else if ([self.decoderController.decoder.currentState isEqualToNumber:@(VCBaseDecoderStateInit)]) {
        [self.decoderController startParse];
    }
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
