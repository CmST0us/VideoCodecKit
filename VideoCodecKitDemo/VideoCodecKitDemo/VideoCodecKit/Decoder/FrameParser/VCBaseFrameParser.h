//
//  VCBaseFrameParser.h
//  VideoCodecKitDemo
//
//  Created by CmST0us on 2018/9/9.
//  Copyright © 2018年 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VCFrameTypeProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class VCBaseFrameParser;
@protocol VCFrameParserDataSource<NSObject>
- (NSData *)feedDataForFrameParser:(VCBaseFrameParser *)frameParser;
@end

@protocol VCBaseFrameParserDelegate<NSObject>
- (void)frameParserDidParseFrame:(id<VCFrameTypeProtocol>)aFrame;
@end

@interface VCBaseFrameParser : NSObject

@property (nonatomic, weak) id<VCFrameParserDataSource> dataSource;
@property (nonatomic, weak) id<VCBaseFrameParserDelegate> delegate;

@property (nonatomic, assign) NSUInteger pasrseCount;
/**
 should use delegate callback. Default is YES
 */
@property (nonatomic, assign) BOOL useDelegate;

/**
 解码得到一帧就返回

 @param buffer 缓冲区
 @param length 缓冲区大小
 @param usedLength 使用的缓冲区大小(inout)
 @return 一帧
 */
- (id<VCFrameTypeProtocol>)parseData:(uint8_t *)buffer
                              length:(NSInteger)length
                          usedLength:(NSInteger *)usedLength;

/**
 解码一帧向delegate通知一次。

 @param buffer 缓冲区
 @param length 缓冲区大小
 @return 使用的缓冲区大小 -1为错误
 */
- (NSInteger)parseData:(void *)buffer
                length:(NSInteger)length;

/**
 解码一帧向block回调一次。不会通知delegate
 
 @param buffer 缓冲区
 @param length 缓冲区大小
 @param block 回调block
 @return 使用的缓冲区大小 -1为错误
 */
- (NSInteger)parseData:(void *)buffer
                length:(NSInteger)length
            completion:(void (^)(id<VCFrameTypeProtocol> frame))block;

- (void)reset;

@end

NS_ASSUME_NONNULL_END
