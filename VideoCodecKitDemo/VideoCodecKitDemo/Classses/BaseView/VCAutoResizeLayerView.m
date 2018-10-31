//
//  VCAutoResizeLayerView.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/10/31.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import "VCAutoResizeLayerView.h"
@interface VCAutoResizeLayerView ()
@property (nonatomic, strong) NSMutableArray *targetLayers;
@end

@implementation VCAutoResizeLayerView
- (void)addAutoResizeSubLayer:(CALayer *)layer {
    if (self.targetLayers == nil) {
        self.targetLayers = [NSMutableArray array];
    }
    [self.layer addSublayer:layer];
    [self.targetLayers addObject:layer];
}

- (void)removeAutoResizeSubLayer:(CALayer *)layer {
    if (self.targetLayers == nil) {
        return;
    }
    [self.targetLayers removeObject:layer];
    [layer removeFromSuperlayer];
}

- (void)layoutSubviews {
    for (CALayer *layer in self.targetLayers) {
        if ([layer isKindOfClass:[CALayer class]]) {
            [layer setFrame:self.bounds];
        }
    }
}
@end
