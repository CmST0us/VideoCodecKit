//
//  VCBaseImage.h
//  VideoCodecKit
//
//  Created by CmST0us on 2018/10/21.
//  Copyright © 2018 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>

@interface VCBaseImage : NSObject {
    @protected
    CVPixelBufferRef _pixelBuffer;
}
// 显示优先级
@property (nonatomic, strong) NSMutableDictionary *userInfo;
@property (nonatomic, readonly) CVPixelBufferRef pixelBuffer;

@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;

- (instancetype)initWithPixelBuffer:(CVPixelBufferRef)pixelBuffer;
@end

