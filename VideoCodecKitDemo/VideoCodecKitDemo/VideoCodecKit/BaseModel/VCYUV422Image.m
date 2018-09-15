//
//  VCYUV422Image.m
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/16.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import "VCYUV422Image.h"

@implementation VCYUV422Image
- (instancetype)initWithWidth:(NSUInteger)width
                       height:(NSUInteger)height
                  bytesPerRow:(NSUInteger)bytesPerRow {
    self = [super self];
    if (self) {
        _width = width;
        _height = height;
    }
    return self;
}

- (void)dealloc {
    if (self.luma != nil) {
        free(self.luma);
        self.luma = nil;
        self.lumaSize = 0;
    }
    
    if (self.chromaB != nil) {
        free(self.chromaB);
        self.chromaB = nil;
        self.chromaBSize = 0;
    }
    
    if (self.chromaR != nil) {
        free(self.chromaR);
        self.chromaR = nil;
        self.chromaRSize = 0;
    }
}
@end
