//
//  ViewController.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/8.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <KVSig/KVSig.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

#import "ViewController.h"
#import "VCDecodeController.h"
#import "VCYUV420PImage.h"
#import "VCSampleBufferRender.h"
#import "VCPreviewer.h"

@interface ViewController ()
@property (nonatomic, strong) VCDecodeController *decoderController;
@property (nonatomic, assign) NSInteger decodeFrameCount;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.decoderController = [[VCDecodeController alloc] init];
    self.decoderController.previewer.watermark = 30;
    self.decoderController.previewer.previewType = VCPreviewerTypeVTRawH264;
//    self.decoderController.parseFilePath = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"h264"];
    self.decoderController.parseFilePath = @"/Users/cmst0us/Desktop/4k.h264";
    self.decoderController.previewer.fps = 30;
    [self setupDisplayLayer];
    [self bindData];
}

- (void)setupDisplayLayer {
    [self.decoderController.previewer.render attachToLayer:self.view.layer];
}

- (void)bindData {
    weakSelf(target);

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    if ([self.decoderController.previewer.decoder.currentState isEqualToNumber:@(VCBaseDecoderStateRunning)]) {
        [self.decoderController stopParse];
    } else if ([self.decoderController.previewer.decoder.currentState isEqualToNumber:@(VCBaseDecoderStateStop)]) {
        [self.decoderController startParse];
    } else if ([self.decoderController.previewer.decoder.currentState isEqualToNumber:@(VCBaseDecoderStateInit)]) {
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
