//
//  VCDemoDecodeSBDLViewController.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/10/30.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import <KVSig/KVSig.h>
#import "VCDemoDecodeSBDLViewController.h"
#import "VCDecodeController.h"

@interface VCDemoDecodeSBDLViewController ()
@property (nonatomic, strong) UIView *previewerView;
@property (nonatomic, strong) UILabel *hintInfoLabel;

@property (nonatomic, strong) VCDecodeController *decoderController;
@property (nonatomic, assign) NSInteger decodeFrameCount;

@property (nonatomic, strong) UITapGestureRecognizer *playGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *stopGestureRecognizer;

@property (nonatomic, strong) dispatch_queue_t encodeWorkingQueue;
@end

@implementation VCDemoDecodeSBDLViewController

#pragma mark - Override

- (void)customInit {
    [super customInit];
    
    [self createViews];
    [self setupViews];
    [self createConstraints];
    
    self.encodeWorkingQueue = dispatch_queue_create("encode_work_queue", DISPATCH_QUEUE_SERIAL);
    self.decoderController = [[VCDecodeController alloc] init];
    self.decoderController.previewer.previewType = VCPreviewerTypeVTLiveH264VideoOnly;
    self.decoderController.parseFilePath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"h264"];
    
    self.playGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playGestureHandler)];
    self.playGestureRecognizer.numberOfTouchesRequired = 1;
    self.playGestureRecognizer.numberOfTapsRequired = 1;
    self.stopGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stopGestureHandler)];
    self.stopGestureRecognizer.numberOfTouchesRequired = 2;
    self.stopGestureRecognizer.numberOfTapsRequired = 1;
    
    [self.previewerView addGestureRecognizer:self.playGestureRecognizer];
    [self.previewerView addGestureRecognizer:self.stopGestureRecognizer];
    
    [self bindData];
}

#pragma mark - Private
- (void)createViews {
    self.previewerView = [[UIView alloc] init];
    [self.view addSubview:self.previewerView];
    self.hintInfoLabel = [[UILabel alloc] init];
    [self.view addSubview:self.hintInfoLabel];
}

- (void)setupViews {
    self.previewerView.backgroundColor = [UIColor clearColor];
    self.hintInfoLabel.text = NSLocalizedString(@"单指轻点播放/暂停，双指轻点停止播放", nil);
    self.hintInfoLabel.textAlignment = NSTextAlignmentRight;
    [self.hintInfoLabel setFont:[UIFont systemFontOfSize:14 weight:UIFontWeightThin]];
    [self.hintInfoLabel sizeToFit];
}

- (void)createConstraints {
    [self.previewerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.hintInfoLabel.mas_bottom).offset(8);
    }];
    [self.hintInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view.mas_rightMargin).offset(-4);
        make.baseline.mas_equalTo(self.backButton.mas_baseline);
    }];
}

- (void)setupDisplayLayer {
    UIView *renderView = self.decoderController.previewer.render.renderView;
    [renderView removeFromSuperview];
    [self.previewerView addSubview:renderView];
    [renderView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.previewerView);
    }];
}

- (void)bindData {
    weakSelf(target);
    [self.decoderController addKVSigObserver:self forKeyPath:KVSKeyPath([self decoderController].previewer.decoder.fps) handle:^(NSObject *oldValue, NSObject *newValue) {
        if (newValue != nil && [newValue isKindOfClass:[NSNumber class]]) {
            NSNumber *fpsNumber = (NSNumber *)newValue;
            target.decoderController.previewer.fps = [fpsNumber integerValue];
        }
    }];
}
#pragma mark - Lift Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [self setupDisplayLayer];
}

#pragma mark - Action
- (void)playGestureHandler {
    if ([self.decoderController.previewer.currentState isEqualToInteger:VCBaseCodecStateRunning]) {
        [self.decoderController.previewer pause];
    } else if ([self.decoderController.previewer.currentState isEqualToInteger:VCBaseCodecStatePause]) {
        [self.decoderController.previewer resume];
    } else if ([self.decoderController.previewer.currentState isEqualToInteger:VCBaseCodecStateReady]) {
        [self.decoderController startParse];
        [self setupDisplayLayer];
    } else if ([self.decoderController.previewer.currentState isEqualToInteger:VCBaseCodecStateStop]) {
        [self.decoderController startParse];
        [self setupDisplayLayer];
    }
}

- (void)stopGestureHandler {
    if ([self.decoderController.previewer.currentState isEqualToInteger:VCBaseCodecStateStop]) {
        [self.decoderController startParse];
        [self setupDisplayLayer];
    } else if ([self.decoderController.previewer.currentState isEqualToInteger:VCBaseCodecStateReady]) {
        [self.decoderController startParse];
        [self setupDisplayLayer];
    } else {
        [self.decoderController stopParse];
    }
}

- (void)onBack:(UIButton *)button {
    [super onBack:button];
    [self.decoderController stopParse];
}
@end
