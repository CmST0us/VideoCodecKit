//
//  VCBaseAudioDecoder.m
//  VideoCodecKit
//
//  Created by CmST0us on 2018/11/6.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import "VCBaseAudioDecoder.h"

@implementation VCBaseAudioDecoder
- (instancetype)init {
    self = [super init];
    if (self) {
        _delegate = nil;
    }
    return self;
}

#pragma mark - Override Method
- (BOOL)setup {
    if ([super setup]) {
        [self commitStateTransition];
        return YES;
    } else {
        [self rollbackStateTransition];
        return NO;
    }
}

- (BOOL)run {
    if ([super run]) {
        [self commitStateTransition];
        return YES;
    } else {
        [self rollbackStateTransition];
        return NO;
    }
}

- (BOOL)invalidate {
    if ([super invalidate]) {
        [self commitStateTransition];
        return YES;
    } else {
        [self rollbackStateTransition];
        return NO;
    }
}

- (BOOL)pause {
    if ([super pause]) {
        [self commitStateTransition];
        return YES;
    } else {
        [self rollbackStateTransition];
        return NO;
    }
}

- (BOOL)resume {
    if ([super resume]) {
        [self commitStateTransition];
        return YES;
    } else {
        [self rollbackStateTransition];
        return NO;
    }
}

- (void)decodeFrame:(VCBaseFrame *)frame completion:(void (^)(VCBaseAudio *))block {
    if (self.currentState.unsignedIntegerValue != VCBaseCodecStateRunning) {
        return;
    }
}

- (void)decodeWithFrame:(VCBaseFrame *)frame {
    if (self.currentState.unsignedIntegerValue != VCBaseCodecStateRunning) {
        return;
    }
}
@end
