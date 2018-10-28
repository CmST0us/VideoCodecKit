//
//  VCBaseEncoder.m
//  VideoCodecKit
//
//  Created by CmST0us on 2018/10/23.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import "VCBaseEncoder.h"

@implementation VCBaseEncoder

- (instancetype)init {
    self = [super init];
    if (self) {
        _config = nil;
    }
    return self;
}

- (instancetype)initWithConfig:(VCBaseEncoderConfig *)config {
    self = [self init];
    if (self) {
        _config = config;
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

- (void)encodeWithImage:(VCBaseImage *)image {
    if ([self.currentState isEqualToInteger:VCBaseCodecStateRunning]) {
        return;
    }
    return;
}

- (VCBaseFrame *)encode:(VCBaseImage *)image {
    if ([self.currentState isEqualToInteger:VCBaseCodecStateRunning]) {
        return nil;
    }
    return nil;
}

- (void)encodeImage:(VCBaseImage *)image withCompletion:(void (^)(VCBaseFrame *))block {
    if ([self.currentState isEqualToInteger:VCBaseCodecStateRunning]) {
        return;
    }
    return;
}

@end
