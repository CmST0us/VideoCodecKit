//
//  VCDecodeController.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/9.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import "VCDecodeController.h"

#define kVCDefaultBufferSize 4096

@interface VCDecodeController ()
@property (nonatomic, strong) NSThread *workThread;
@end


@implementation VCDecodeController

- (instancetype)init {
    self = [super init];
    if (self) {
        _parser = [[VCH264FFMpegFrameParser alloc] init];
        _parser.delegate = self;
        _parser.useDelegate = NO;
    }
    return self;
}

- (void)workingThread {
    @autoreleasepool {
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
                [self.parser parseData:fileBuffer length:readLen copyData:YES];
            }
            memset(fileBuffer, 0, kVCDefaultBufferSize);
        }
        free(fileBuffer);
    }
}

- (void)startParse {
    self.workThread = [[NSThread alloc] initWithTarget:self selector:@selector(workingThread) object:nil];
    [self.workThread start];
}

- (void)stopParse {
    [self.workThread cancel];
    self.workThread = nil;
}
@end
