//
//  VCDecodeController.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/9.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import "VCDecodeController.h"
#import <KVSig/KVSig.h>

#define kVCDefaultBufferSize 1500

@interface VCDecodeController ()
@property (nonatomic, strong) NSThread *workThread;
@property (nonatomic, strong) dispatch_semaphore_t workThreadSem;
@end


@implementation VCDecodeController

- (instancetype)init {
    self = [super init];
    if (self) {
        _previewer = [[VCPreviewer alloc] initWithType:VCPreviewerTypeVTLiveH264VideoOnly];
        _workThreadSem = dispatch_semaphore_create(0);
    }
    return self;
}

- (void)workingThread {
    weakSelf(target);
    @autoreleasepool{
        // do not release
        NSInputStream *stream = [[NSInputStream alloc] initWithFileAtPath:self.parseFilePath];
        [stream open];
        while (![[NSThread currentThread] isCancelled]) {
            // file reader
            void *fileBuffer = malloc(kVCDefaultBufferSize);
            NSInteger readLen = [stream read:fileBuffer maxLength:kVCDefaultBufferSize];
            if (readLen <= 0) {
                // eof or error
                [self.previewer endFeedData];
                break;
            } else {
                // 自旋锁
                while (![self.previewer feedData:fileBuffer length:readLen]) {
                    // 1Hz 重试
                    if ([[NSThread currentThread] isCancelled]) {
                        break;
                    }
                    [NSThread sleepForTimeInterval:0.01];
                };
            }
        }
        dispatch_semaphore_signal(self.workThreadSem);
    }
}

- (void)workingThread1 {
    weakSelf(target);
    @autoreleasepool{
        NSData *data = [[NSData alloc] initWithContentsOfFile:self.parseFilePath];
        [self.previewer feedData:data.bytes length:data.length];
        dispatch_semaphore_signal(self.workThreadSem);
    }
}

- (void)startParse {
    [self.previewer run];
    self.workThread = [[NSThread alloc] initWithTarget:self selector:@selector(workingThread) object:nil];
    self.workThread.name = @"workThread";
    [self.workThread start];
}

- (void)stopParse {
    [self.workThread cancel];
    self.workThread = nil;
    dispatch_semaphore_wait(self.workThreadSem, DISPATCH_TIME_FOREVER);
    [self.previewer stop];
}

-(void)previewer:(VCPreviewer *)aPreviewer didProcessImage:(id<VCImageTypeProtocol>)aImage {
    
}

@end
