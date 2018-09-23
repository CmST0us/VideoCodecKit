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

#define kVCPreviewSafeQueueSize 100

@interface VCPreviewer () {
    sem_t *_parserThreadSem;
    sem_t *_decoderThreadSem;
}
@property (nonatomic, strong) VCSafeQueue *dataQueue;
@property (nonatomic, strong) NSThread *parserThread;
@property (nonatomic, strong) NSThread *decoderThread;
@property (nonatomic, strong) CADisplayLink *displayLink;

@end

@implementation VCPreviewer

- (NSDictionary *)supportPreviewerComponent {
    /*
     VCPreviewerType: [parser_class, decoder_class, render_class]
     
     */
    return @{
                // VCPreviewerTypeRawH264 使用的组件
               @(VCPreviewerTypeFFmpegRawH264):@[NSStringFromClass([VCH264FFmpegFrameParser class]),
                                                 NSStringFromClass([VCH264FFmpegDecoder class]),
                                                 NSStringFromClass([VCSampleBufferRender class])],
               
               // VCPreviewerTypeVTRawH264 使用的组件
               @(VCPreviewerTypeVTRawH264):@[NSStringFromClass([VCH264FFmpegFrameParser class]),
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
        
        _parserThreadSem = sem_open("_parserThreadSem", 0);
        _decoderThreadSem = sem_open("_decoderThreadSem", 0);
    }
    return self;
}

- (instancetype)initWithType:(VCPreviewerType)previewType {
    self = [self init];
    if (self) {
        self.previewType = previewType;
        NSDictionary *supportComponents = [self supportPreviewerComponent];
        Class renderClass = NSClassFromString(supportComponents[@(previewType)][2]);
        if ([renderClass conformsToProtocol:@protocol(VCBaseRenderProtocol)]) {
            _render = [[renderClass alloc] init];
        }
        [self reset];
    }
    return self;
}

- (void)dealloc {
    [self free];
    
    sem_close(_parserThreadSem);
    sem_close(_decoderThreadSem);
}

- (void)setPreviewType:(VCPreviewerType)previewType {
    if (self.previewType == previewType) {
        return;
    }
    _previewType = previewType;
    [self free];
    [self reset];
}

- (void)setFps:(NSInteger)fps {
    if (_fps == fps) {
        return;
    }
    _fps = fps;
    if (@available(iOS 10, *)) {
        self.displayLink.preferredFramesPerSecond = _fps;
    } else {
        self.displayLink.frameInterval = MIN(60 / _fps, 0);
    }
}
- (void)free {
    [self.parserThread cancel];
    [self.decoderThread cancel];
    
    sem_wait(_parserThreadSem);
    sem_wait(_decoderThreadSem);
    
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
}

- (void)reset {
    NSDictionary *supportComponents = [self supportPreviewerComponent];
    Class parserClass = NSClassFromString(supportComponents[@(self.previewType)][0]);
    Class decoderClass = NSClassFromString(supportComponents[@(self.previewType)][1]);
    
    if (![parserClass isSubclassOfClass:[VCBaseFrameParser class]]) {
        return;
    }
    
    if (![decoderClass isSubclassOfClass:[VCBaseDecoder class]]) {
        return;
    }
    
    _parser = [[parserClass alloc] init];
    _parser.delegate = self;
    
    _decoder = [[decoderClass alloc] init];
    _decoder.delegate = self;
    
    _dataQueue = [[VCSafeQueue alloc] initWithSize:kVCPreviewSafeQueueSize];
    _parserQueue = [[VCSafeObjectQueue alloc] initWithSize:kVCPreviewSafeQueueSize];
    _imageQueue = [[VCSafeObjectQueue alloc] initWithSize:kVCPreviewSafeQueueSize];
    
    _parserThread = [[NSThread alloc] initWithTarget:self selector:@selector(parserWorkThread) object:nil];
    _parserThread.name = @"VCPreviewer.parserThread";
    _decoderThread = [[NSThread alloc] initWithTarget:self selector:@selector(decoderWorkThread) object:nil];
    _decoderThread.name = @"VCPreviewer.decoderThread";
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkLoop)];
    
}

- (void)run {
    if ([[_decoder currentState] isEqualToNumber:@(VCBaseDecoderStateInit)]||
        [_decoder.currentState isEqualToNumber:@(VCBaseDecoderStateStop)]) {
        [_decoder FSM(setup)];
    }
    [_decoder FSM(run)];
    [_parserThread start];
    [_decoderThread start];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stop {
    [_decoder FSM(invalidate)];
    [_parserThread cancel];
    [_decoderThread cancel];
    [_displayLink invalidate];
    [self free];
    [self reset];
}

- (BOOL)pushData:(uint8_t *)data length:(int)length {
    if (self.dataQueue == nil) {
        return NO;
    }
    return [self.dataQueue push:data length:length];
}

- (BOOL)canPushData {
    if (self.dataQueue == nil) {
        return NO;
    }
    return ![self.dataQueue isFull];
}
- (void)parserWorkThread {
    @autoreleasepool {
        while (![[NSThread currentThread] isCancelled]) {
            uint8_t *data = NULL;
            int dataLength = 0;
            data = [self.dataQueue pull:&dataLength];
            if (data != NULL) {
                [self.parser parseData:data length:dataLength];
                free(data);
                data = NULL;
            }
        }
        sem_post(_parserThreadSem);
    }
}

- (void)decoderWorkThread {
    @autoreleasepool {
        while (![[NSThread currentThread] isCancelled]) {
            NSObject *frame = [self.parserQueue pull];
            if (frame != nil && [frame conformsToProtocol:@protocol(VCFrameTypeProtocol)]) {
                [self.decoder decodeWithFrame:(id<VCFrameTypeProtocol>)frame];
            }
        }
        sem_post(_decoderThreadSem);
    }
}

- (void)displayLinkLoop {
    @autoreleasepool {
        NSObject *image = [self.imageQueue pull];
        if (image != nil && [image conformsToProtocol:@protocol(VCImageTypeProtocol)]) {
            [self.render renderImage:(id<VCImageTypeProtocol>)image];
        }
    }
}

#pragma mark - Parser Delegate Method
- (void)frameParserDidParseFrame:(id<VCFrameTypeProtocol>)aFrame {
    if (self.parserQueue) {
        while (![self.parserQueue push:aFrame]) {
            sleep(1);
        }
    }
}

#pragma mark - Decoder Delegate Method
- (void)decoder:(VCBaseDecoder *)decoder didProcessImage:(id<VCImageTypeProtocol>)image {
    if (self.imageQueue) {
        while (![self.imageQueue push:image]) {
            sleep(1);
        }
    }
}

@end
