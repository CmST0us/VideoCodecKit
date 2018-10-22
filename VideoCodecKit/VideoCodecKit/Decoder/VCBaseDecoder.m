//
//  VCBaseDecoder.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/9.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import "VCBaseDecoder.h"

#define kVCBaseDecoderDefaultFPS (30)

@interface VCBaseDecoder ()

@end

@implementation VCBaseDecoder
@synthesize fps = _fps;

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithConfig:(VCBaseDecoderConfig *)config {
    self = [self init];
    if (self) {
        _config = config;
        _fps = kVCBaseDecoderDefaultFPS;
    }
    return self;
}

#pragma mark - Public Method

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

- (VCBaseFrame *)decode:(VCBaseFrame *)frame {
    if (self.currentState.unsignedIntegerValue != VCBaseCodecStateRunning) {
        return nil;
    }
    return nil;
}


- (void)decodeFrame:(VCBaseFrame *)frame
         completion:(void (^)(VCBaseImage *))block {
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
