//
//  VCH264FFmpegFrameParserBuffer.h
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/9.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface VCH264FFmpegFrameParserBuffer : NSObject

@property (nonatomic, assign) uint8_t *data;
@property (nonatomic, assign) NSUInteger length;
@property (nonatomic, readonly) BOOL isCopyData;

- (instancetype)initWithBuffer:(void *)buffer
                        length:(NSUInteger)length
                      copyData:(BOOL)isCopy;

- (instancetype)initWithData:(NSData *)data
                    copyData:(BOOL *)isCopy;


- (instancetype)advancedBy:(NSInteger)step;
@end
