//
//  VCPreviewer.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/21.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <dispatch/dispatch.h>
#import <semaphore.h>

#import "VCPreviewer.h"
#import "VCSafeQueue.h"
#import "VCSafeObjectQueue.h"
#import "VCPriorityObjectQueue.h"
#import "VCHeapPriorityObjectQueue.h"

#define kVCPreviewSafeQueueSize 20

@interface VCPreviewer ()

@property (nonatomic, strong) VCSafeQueue *dataQueue;
@property (nonatomic, strong) NSThread *parserThread;
@property (nonatomic, strong) NSThread *decoderThread;
@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, strong) dispatch_semaphore_t parserThreadSem;
@property (nonatomic, strong) dispatch_semaphore_t decoderThreadSem;

@property (nonatomic, strong) VCSafeObjectQueue *parserQueue;
@property (nonatomic, strong) VCPriorityObjectQueue *imageQueue;
@end

@implementation VCPreviewer
@synthesize watermark = _watermark;

- (NSDictionary *)supportPreviewerComponent {
    /*
     VCPreviewerType: [parser_class, decoder_class, render_class]
     
     */
    return @{
                // VCPreviewerTypeFFmpegLiveH264VideoOnly 使用的组件
               @(VCPreviewerTypeFFmpegLiveH264VideoOnly):@[NSStringFromClass([VCH264FFmpegFrameParser class]),
                                                           NSStringFromClass([VCH264FFmpegDecoder class]),
                                                           NSStringFromClass([VCSampleBufferRender class])],
               
               // VCPreviewerTypeVTLiveH264VideoOnly 使用的组件
               @(VCPreviewerTypeVTLiveH264VideoOnly):@[NSStringFromClass([VCH264FFmpegFrameParser class]),
                                                       NSStringFromClass([VCVTH264Decoder class]),
                                                       NSStringFromClass([VCSampleBufferRender class])],
               };
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _parser = nil;
        _decoder = nil;
        _render = nil;
        _parserQueue = nil;
        _imageQueue = nil;
        _delegate = nil;
        _watermark = 3;
        _parserThreadSem = dispatch_semaphore_create(0);
        _decoderThreadSem = dispatch_semaphore_create(0);
    }
    return self;
}

- (instancetype)initWithType:(VCPreviewerType)previewType {
    self = [self init];
    if (self) {
        _previewType = previewType;
        NSDictionary *supportComponents = [self supportPreviewerComponent];
        Class renderClass = NSClassFromString(supportComponents[@(previewType)][2]);
        if ([renderClass conformsToProtocol:@protocol(VCBaseRenderProtocol)]) {
            _render = [[renderClass alloc] init];
        }
    }
    return self;
}

- (void)dealloc {
    [self free];
}

- (CADisplayLink *)displayLink {
    if (_displayLink != nil) {
        return _displayLink;
    }
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkLoop)];
    return _displayLink;
}

- (void)setWatermark:(NSInteger)watermark {
    if (_imageQueue != nil) {
        _watermark = watermark;
        _imageQueue.watermark = watermark;
    }
}

- (NSInteger)watermark {
    return _watermark;
}

- (void)setPreviewType:(VCPreviewerType)previewType {
    if (self.previewType == previewType) {
        return;
    }
    _previewType = previewType;
    [self invalidate];
    [self free];
    [self setup];
}

- (void)setFps:(NSInteger)fps {
    _fps = fps;
    if (@available(iOS 10, *)) {
        self.displayLink.preferredFramesPerSecond = _fps;
    } else {
        self.displayLink.frameInterval = MIN(60 / _fps, 0);
    }
}

- (void)waitDecoderThreadStop {
    if ([self.decoderThread isExecuting]) {
        [self.decoderThread cancel];
        dispatch_semaphore_wait(_decoderThreadSem, DISPATCH_TIME_FOREVER);
    }
}

- (void)waitParserThreadStop {
    if ([self.parserThread isExecuting]) {
        [self.parserThread cancel];
        dispatch_semaphore_wait(_parserThreadSem, DISPATCH_TIME_FOREVER);
    }
}

- (void)free {
    // 特别注意这里需要先关解码器线程，再关组帧线程。
    // 后面如果还要加线程的话，按照pipeline从结束到开始的顺序结束线程
    [self waitDecoderThreadStop];
    [self waitParserThreadStop];
    
    if (self.dataQueue) {
        [self.dataQueue clear];
        self.dataQueue = nil;
    }
    if (self.parserQueue) {
        [self.parserQueue clear];
        self.parserQueue = nil;
    }
    
    if (self.imageQueue) {
        [self.imageQueue clear];
        self.imageQueue = nil;
    }
    _displayLink = nil;
}

#pragma mark - Public Method
- (BOOL)setup {
    if (![super setup]) {
        [self rollbackStateTransition];
        return NO;
    }
    
    NSDictionary *supportComponents = [self supportPreviewerComponent];
    Class parserClass = NSClassFromString(supportComponents[@(self.previewType)][0]);
    Class decoderClass = NSClassFromString(supportComponents[@(self.previewType)][1]);
    
    if (![parserClass isSubclassOfClass:[VCBaseFrameParser class]]) {
        [self rollbackStateTransition];
        return NO;
    }
    
    if (![decoderClass isSubclassOfClass:[VCBaseDecoder class]]) {
        [self rollbackStateTransition];
        return NO;
    }
    
    _parser = [[parserClass alloc] init];
    _parser.delegate = self;
    
    _decoder = [[decoderClass alloc] init];
    _decoder.delegate = self;
    
    _dataQueue = [[VCSafeQueue alloc] initWithSize:kVCPreviewSafeQueueSize];
    _parserQueue = [[VCSafeObjectQueue alloc] initWithSize:kVCPreviewSafeQueueSize];
    _imageQueue = [[VCPriorityObjectQueue alloc] initWithSize:kVCPreviewSafeQueueSize isThreadSafe:YES];
    _imageQueue.watermark = _watermark;
    
    _parserThread = [[NSThread alloc] initWithTarget:self selector:@selector(parserWorkThread) object:nil];
    _parserThread.name = @"VCPreviewer.parserThread";
    _parserThread.qualityOfService = NSQualityOfServiceUtility;
    _decoderThread = [[NSThread alloc] initWithTarget:self selector:@selector(decoderWorkThread) object:nil];
    _decoderThread.name = @"VCPreviewer.decoderThread";
    _decoderThread.qualityOfService = NSQualityOfServiceDefault;
    
    [self commitStateTransition];
    return YES;
}

- (BOOL)run {
    if (![super run]) {
        [self rollbackStateTransition];
        return NO;
    }
    
    if ([[_decoder currentState] isEqualToNumber:@(VCBaseCodecStateInit)]||
        [_decoder.currentState isEqualToNumber:@(VCBaseCodecStateStop)]) {
        [_decoder setup];
    }
    [_decoder run];
    [_parserThread start];
    [_decoderThread start];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
    [self commitStateTransition];
    return YES;
}

- (BOOL)pause {
    if (![super pause]) {
        [self rollbackStateTransition];
        return NO;
    }
    [self.displayLink setPaused:YES];
    [self commitStateTransition];
    return YES;
}

- (BOOL)resume {
    if (![super resume]) {
        [self rollbackStateTransition];
        return NO;
    }
    [self.displayLink setPaused:NO];
    [self commitStateTransition];
    return YES;
}

- (BOOL)invalidate {
    if (![super invalidate]) {
        [self rollbackStateTransition];
        return NO;
    }
    
    [_parserThread cancel];
    [_decoderThread cancel];
    if ([_decoder.currentState isKindOfState:@[@(VCBaseCodecStateRunning),
                                               @(VCBaseCodecStateReady),
                                               @(VCBaseCodecStatePause)]]) {
        [_displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        [_decoder invalidate];
    }
    [self free];
    [self commitStateTransition];
    return YES;
}

#pragma mark - Feed Data
- (BOOL)feedData:(uint8_t *)data length:(int)length {
    if (self.dataQueue == nil) {
        return NO;
    }
    return [self.dataQueue push:data length:length];
}

- (BOOL)canFeedData {
    if (self.dataQueue == nil) {
        return NO;
    }
    return ![self.dataQueue isFull];
}

- (void)endFeedData {
    if (self.dataQueue != nil && self.imageQueue != nil) {
        self.imageQueue.watermark = 0;
    }
    self.imageQueue.shouldWaitWhenPullFailed = YES;
}

#pragma mark - Thread
- (void)parserWorkThread {
    while (![[NSThread currentThread] isCancelled]) {
        @autoreleasepool {
            uint8_t *data = NULL;
            int dataLength = 0;
            data = [self.dataQueue pull:&dataLength];
            if (data != NULL) {
                [self.parser parseData:data length:dataLength];
                free(data);
                data = NULL;
            }
        }
    }
    dispatch_semaphore_signal(_parserThreadSem);
}

- (void)decoderWorkThread {
    while (![[NSThread currentThread] isCancelled]) {
        @autoreleasepool {
            NSObject *frame = [self.parserQueue pull];
            if (frame != nil && [[frame class] isSubclassOfClass:[VCBaseFrame class]]) {
                [self.decoder decodeWithFrame:(VCBaseFrame *)frame];
            }
        }
    }
    dispatch_semaphore_signal(_decoderThreadSem);
}

- (void)displayLinkLoop {
    @autoreleasepool {
        if (self.displayLink.isPaused == YES) return;
        
        NSObject *image = [self.imageQueue pull];
        if (image != nil
            && [[image class] isSubclassOfClass:[VCBaseImage class]]) {
            [self.render renderImage:(VCBaseImage *)image];
            // [TODO] Use Delegate Thread
            if (self.delegate) {
                dispatch_queue_t workingQueue = [self.delegate processWorkingQueue];
                dispatch_async(workingQueue, ^{
                    [self.delegate previewer:self didProcessImage:(VCBaseImage *)image];
                });
            }
        }
    }
}

#pragma mark - Parser Delegate Method
- (void)frameParserDidParseFrame:(VCBaseFrame *)aFrame {
    if (aFrame == nil) {
        return;
    }
    if (self.parserQueue) {
        while (![self.parserQueue push:aFrame]) {
            if ([[NSThread currentThread] isCancelled]) {
                break;
            } else {
                [NSThread sleepForTimeInterval:0.01];
            }
        }
    }
}

#pragma mark - Decoder Delegate Method
- (void)decoder:(VCBaseDecoder *)decoder didProcessImage:(VCBaseImage *)image {
    if (image == nil) {
        return;
    }
    
    if (self.imageQueue) {
        NSInteger priority = 0;
        NSNumber *priorityNumber = [image.userInfo objectForKey:kVCBaseImageUserInfoFrameIndexKey];
        if (priorityNumber != nil
            && [priorityNumber isKindOfClass:[NSNumber class]]) {
            priority = [priorityNumber integerValue];
        } else {
            priority = 0;
        }
        while (![self.imageQueue push:image priority:priority]) {
            if ([[NSThread currentThread] isCancelled]) {
                break;
            } else {
                [NSThread sleepForTimeInterval:0.01];
            }
        }
    }
}

@end
