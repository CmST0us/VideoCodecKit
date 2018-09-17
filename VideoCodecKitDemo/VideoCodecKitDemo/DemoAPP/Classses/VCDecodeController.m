//
//  VCDecodeController.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/9.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import "VCDecodeController.h"
#import <KVSig/KVSig.h>

#define kVCDefaultBufferSize 10240

@interface VCDecodeController ()
@property (nonatomic, strong) NSThread *workThread;
@property (nonatomic, strong) dispatch_semaphore_t workThreadSem;
@end


@implementation VCDecodeController

- (instancetype)init {
    self = [super init];
    if (self) {
        _decoder = [[VCH264FFmpegDecoder alloc] init];
        _workThreadSem = dispatch_semaphore_create(0);
    }
    return self;
}

- (void)workingThread {
    weakSelf(target);
    @autoreleasepool{
        void *fileBuffer = malloc(kVCDefaultBufferSize);
        
        NSInputStream *stream = [[NSInputStream alloc] initWithFileAtPath:self.parseFilePath];
        [stream open];
        while (![[NSThread currentThread] isCancelled]) {
            // file reader
            NSInteger readLen = [stream read:fileBuffer maxLength:kVCDefaultBufferSize];
            if (readLen <= 0) {
                // eof or error
                break;
            } else {
                [self.decoder.parser parseData:fileBuffer length:readLen copyData:YES completion:^(id<VCFrameTypeProtocol> _Nonnull frame) {
                    [target.decoder decodeFrame:frame completion:^(id<VCFrameTypeProtocol>  _Nonnull frame) {
                        target.frame = frame;
                    }];
                }];
            }
            memset(fileBuffer, 0, kVCDefaultBufferSize);
        }
        free(fileBuffer);
        dispatch_semaphore_signal(self.workThreadSem);
    }
}

- (void)workingThread1 {
    weakSelf(target);
    @autoreleasepool{
        NSData *data = [[NSData alloc] initWithContentsOfFile:self.parseFilePath];
        [self.decoder.parser parseData:data.bytes length:data.length copyData:NO completion:^(id<VCFrameTypeProtocol> _Nonnull frame) {
            [target.decoder decodeFrame:frame completion:^(id<VCFrameTypeProtocol>  _Nonnull frame) {
                target.frame = frame;
            }];
        }];
        
        dispatch_semaphore_signal(self.workThreadSem);
    }
}

- (void)startParse {
    [self.decoder FSM(setup)];
    [self.decoder FSM(run)];
    self.workThread = [[NSThread alloc] initWithTarget:self selector:@selector(workingThread1) object:nil];
    [self.workThread start];
}

- (void)stopParse {
    [self.workThread cancel];
    self.workThread = nil;
    dispatch_semaphore_wait(self.workThreadSem, DISPATCH_TIME_FOREVER);
    [self.decoder FSM(invalidate)];
}
@end
